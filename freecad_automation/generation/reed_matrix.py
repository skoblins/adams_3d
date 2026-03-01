#!/usr/bin/env python3
"""Export stroik (reed) bodies in a print-ready matrix with text modifier labels.

Generates two STL files:
  - reed_matrix.stl        — all reed variants arranged in a grid
  - reed_matrix_labels.stl — text labels (slicer modifier, different material)

Each reed is oriented to lie on its bottom face and arranged in a grid
that fits the Prusa print area.  Labels show parameter values in the
shortest possible form and are positioned flush with each reed's bottom
face so that after loading into the slicer both files are immediately
ready for slicing.

If REED_MATRIX_BOTTOM_FACE_FEATURE / REED_MATRIX_BOTTOM_FACE are set
in config, that specific face is used for orientation.  Otherwise the
script auto-detects the largest planar face.

Usage:
    freecad.cmd -c "exec(open('.../reed_matrix.py').read())"
  or:
    ./generate.sh reed_matrix
"""

import glob
import itertools
import math
import os
import sys

try:
    _SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
except NameError:
    _SCRIPT_DIR = "/home/adam/adams_3d/freecad_automation/generation"
if _SCRIPT_DIR not in sys.path:
    sys.path.insert(0, _SCRIPT_DIR)

import FreeCAD
import Part

from config import (
    OUTPUT_DIR, STROIK_RANGES, LINEAR_DEFLECTION,
    PRUSA_BED_X, PRUSA_BED_Y, PRUSA_BED_MARGIN,
    REED_MATRIX_BOTTOM_FACE_FEATURE,
    REED_MATRIX_BOTTOM_FACE,
    REED_MATRIX_SPACING,
    REED_MATRIX_LABEL_DEPTH,
    REED_MATRIX_LABEL_MARGIN,
    REED_MATRIX_RAFT_EXTEND,
    REED_MATRIX_RAFT_THICKNESS,
    REED_MATRIX_STL_NAME,
    REED_MATRIX_LABEL_STL_NAME,
    REED_MATRIX_LABEL_PARAMS,
)
from helpers import (
    frange, format_val, export_shape_stl,
    open_project, close_project,
)


# ── Helpers ──────────────────────────────────────────────────────────────


def _find_font():
    """Return (font_dir, font_file) for the first usable .ttf font found."""
    search_dirs = [
        "/usr/share/fonts/liberation-fonts/",
        "/usr/share/fonts/truetype/dejavu/",
        "/usr/share/fonts/truetype/liberation/",
        "/usr/share/fonts/truetype/freefont/",
        "/usr/share/fonts/dejavu/",
        "/usr/share/fonts/gnu-free/",
        "/run/host/fonts/truetype/liberation/",
        "/run/host/fonts/truetype/dejavu/",
        "/run/host/fonts/truetype/freefont/",
    ]
    try:
        import matplotlib
        mpl_fonts = os.path.join(os.path.dirname(matplotlib.__file__),
                                 "mpl-data", "fonts", "ttf") + "/"
        search_dirs.insert(0, mpl_fonts)
    except ImportError:
        pass

    for d in search_dirs:
        if os.path.isdir(d):
            for f in sorted(os.listdir(d)):
                if f.lower().endswith(".ttf") and "emoji" not in f.lower():
                    return d, f

    for base in ["/usr/share/fonts", "/run/host/fonts"]:
        hits = glob.glob(os.path.join(base, "**", "*.ttf"), recursive=True)
        hits = [h for h in hits if "emoji" not in h.lower()]
        if hits:
            h = sorted(hits)[0]
            return os.path.dirname(h) + "/", os.path.basename(h)

    return None, None


def _make_planar_face(wires):
    """Build a planar face from glyph wires (handles holes)."""
    for maker in ("Part::FaceMakerBullseye", "Part::FaceMakerCheese"):
        try:
            face = Part.makeFace(wires, maker)
            if not face.isNull():
                return face
        except Exception:
            pass
    return Part.Face(wires)


def _short_val(v):
    """Format a float in the shortest readable form.

    34.00 → '34'   1.40 → '1.4'   0.20 → '0.2'
    """
    s = f"{v:.2f}"
    if "." in s:
        s = s.rstrip("0")
        if s.endswith("."):
            s = s[:-1]
    return s


def _find_best_flat_face(shape):
    """Auto-detect the largest planar face on the shape for bed orientation."""
    best_face = None
    best_area = 0.0
    for face in shape.Faces:
        try:
            if face.Surface.TypeId == "Part::GeomPlane":
                area = face.Area
                if area > best_area:
                    best_area = area
                    best_face = face
        except Exception:
            pass
    return best_face


def orient_shape_on_face(shape, face):
    """Rotate *shape* so that *face* lies flat on the XY plane at Z=0.

    The face normal ends up pointing -Z (into the build plate) so the
    part rests on that face.  Returns the oriented copy.
    """
    center = face.CenterOfMass
    try:
        uv = face.Surface.parameter(center)
        normal = face.normalAt(uv[0], uv[1]).normalize()
    except Exception:
        normal = face.normalAt(0, 0).normalize()

    desired = FreeCAD.Vector(0, 0, -1)

    oriented = shape.copy()
    shape_center = shape.BoundBox.Center

    if not normal.isEqual(desired, 1e-6):
        if normal.isEqual(-desired, 1e-6):
            # Normal points +Z → flip 180° around X
            oriented.rotate(shape_center, FreeCAD.Vector(1, 0, 0), 180)
        else:
            axis = normal.cross(desired)
            dot = max(-1.0, min(1.0, normal.dot(desired)))
            angle = math.degrees(math.acos(dot))
            oriented.rotate(shape_center, axis, angle)

    # Translate so bottom sits at Z=0 and origin at (0, 0)
    bb = oriented.BoundBox
    oriented.translate(FreeCAD.Vector(-bb.XMin, -bb.YMin, -bb.ZMin))
    return oriented


def build_reed_labels(lines, x, y, face_w, face_h, depth, margin,
                      font_dir, font_file):
    """Build text-label solids for one reed at grid position (x, y).

    *lines* is a list of strings — one per parameter.  Each line is
    rendered separately and stacked vertically within the face footprint.

    The label sits on the Z=0 plane and extrudes *upward* by *depth*
    so it overlaps with the bottom of the reed.  The text is rotated 90°
    to run along the long axis of the reed for maximum readability, then
    mirrored so it reads correctly when viewing the bottom of the printed
    part.

    Returns a list of Part.Shape solids (one per glyph).
    """
    avail_w = face_w - 2.0 * margin
    avail_h = face_h - 2.0 * margin
    if avail_w <= 0 or avail_h <= 0:
        return []

    n_lines = len(lines)
    if n_lines == 0:
        return []

    # Determine orientation: rotate 90° if face_h > face_w (long axis vertical)
    rotate = face_h > face_w
    if rotate:
        fit_w = avail_h   # text width  fits the long dimension
        fit_h = avail_w   # text height fits the short dimension
    else:
        fit_w = avail_w
        fit_h = avail_h

    # Divide available height among lines with small gap
    line_gap = -0.3  # mm between lines (negative = overlap/tighter)
    line_h = (fit_h - (n_lines - 1) * line_gap) / n_lines
    if line_h <= 0:
        return []

    text_height = line_h * 0.55

    face_cx = x + face_w / 2.0
    face_cy = y + face_h / 2.0

    # Left-align edge (with margin + small extra inset)
    left_inset = margin + 0.7
    if rotate:
        face_left = y + left_inset
    else:
        face_left = x + left_inset

    extrude_dir = FreeCAD.Vector(0, 0, depth)
    all_solids = []

    for li, line_text in enumerate(lines):
        # Render this line's text
        for _attempt in range(5):
            wires_per_char = Part.makeWireString(
                line_text, font_dir, font_file, text_height, 0.0)
            if not wires_per_char:
                break

            all_wires = [w for cw in wires_per_char for w in cw]
            if not all_wires:
                break

            bb = Part.makeCompound(all_wires).BoundBox
            if bb.XLength <= fit_w and bb.YLength <= line_h:
                break
            scale = min(fit_w / bb.XLength, line_h / bb.YLength) * 0.95
            text_height *= scale
        else:
            continue

        if not wires_per_char:
            continue

        all_wires = [w for cw in wires_per_char for w in cw]
        if not all_wires:
            continue
        bb = Part.makeCompound(all_wires).BoundBox

        cy_text = bb.YMin + bb.YLength / 2.0

        # Offset for this line within the stacked block
        # Lines stack along the short axis (fit_h direction)
        block_start = -fit_h / 2.0  # relative to face center
        line_center = block_start + li * (line_h + line_gap) + line_h / 2.0

        if rotate:
            # Rotation 90° CCW + X-mirror
            # Short axis = X after rotation, long axis = Y
            # Left-align: map text bb.XMin to face_left (along Y after rot)
            tx = face_cx - cy_text + line_center
            ty = face_left - bb.XMin
            mat = FreeCAD.Matrix(
                0, 1, 0, tx,
                1, 0, 0, ty,
                0, 0, 1, 0,
                0, 0, 0, 1,
            )
        else:
            # No rotation, mirror X; stack along Y
            # Left-align: text right edge maps to face left edge (mirrored)
            tx = face_left + bb.XMin + bb.XLength
            ty = face_cy - cy_text + line_center
            mat = FreeCAD.Matrix(
                -1, 0, 0, tx,
                 0, 1, 0, ty,
                 0, 0, 1, 0,
                 0, 0, 0, 1,
            )

        for char_wires in wires_per_char:
            try:
                transformed = [w.transformGeometry(mat) for w in char_wires]
                face_shape = _make_planar_face(transformed)
                solid = face_shape.extrude(extrude_dir)
                all_solids.append(solid)
            except Exception:
                pass

    return all_solids


# ── Main ─────────────────────────────────────────────────────────────────


def run():
    doc, varset, stroik_body, _ = open_project()

    font_dir, font_file = _find_font()
    if not font_dir:
        print("ERROR: No TrueType font found for labels")
        sys.exit(1)
    print(f"Font: {font_dir}{font_file}")

    orig_vals = {p: getattr(varset, p) for p in STROIK_RANGES}

    param_names = list(STROIK_RANGES.keys())
    param_values = [frange(*STROIK_RANGES[p]) for p in param_names]
    combos = list(itertools.product(*param_values))

    print(f"\n=== reed matrix: {len(combos)} combinations "
          f"({' x '.join(param_names)}) ===\n")

    # Resolve the face feature for orientation
    face_feature = None
    if REED_MATRIX_BOTTOM_FACE_FEATURE:
        face_feature = doc.getObject(REED_MATRIX_BOTTOM_FACE_FEATURE)
        if face_feature is None:
            print(f"WARN: Feature '{REED_MATRIX_BOTTOM_FACE_FEATURE}' not found, "
                  f"will auto-detect flat face")

    # ── Collect oriented shapes ──────────────────────────────────────
    entries = []  # list of (oriented_shape, label_text)

    for combo in combos:
        for pname, pval in zip(param_names, combo):
            setattr(varset, pname, pval)
        doc.recompute()

        tag = "_".join(f"{pn}={format_val(pv)}"
                       for pn, pv in zip(param_names, combo))

        if not stroik_body.Shape.isValid():
            print(f"  SKIP {tag} — invalid shape")
            continue

        # Get the bottom face: try configured face, then auto-detect
        bottom_face = None
        if face_feature and REED_MATRIX_BOTTOM_FACE:
            try:
                bottom_face = face_feature.Shape.getElement(
                    REED_MATRIX_BOTTOM_FACE)
            except Exception:
                pass
        if bottom_face is None and REED_MATRIX_BOTTOM_FACE:
            # Try from body directly
            try:
                bottom_face = stroik_body.Shape.getElement(
                    REED_MATRIX_BOTTOM_FACE)
            except Exception:
                pass
        if bottom_face is None:
            # Auto-detect largest planar face
            bottom_face = _find_best_flat_face(stroik_body.Shape)
            if bottom_face is None:
                print(f"  SKIP {tag} — no planar face found for orientation")
                continue

        oriented = orient_shape_on_face(stroik_body.Shape, bottom_face)

        # Flip 180° around X — Face11 normal points inward, so the
        # default orient puts the part upside-down.
        bb = oriented.BoundBox
        cx = bb.Center
        oriented.rotate(cx, FreeCAD.Vector(1, 0, 0), 180)
        bb = oriented.BoundBox
        oriented.translate(FreeCAD.Vector(-bb.XMin, -bb.YMin, -bb.ZMin))

        # Label text: one line per parameter, shortest form
        label_lines = []
        for p in REED_MATRIX_LABEL_PARAMS:
            if p in param_names:
                idx = param_names.index(p)
                label_lines.append(_short_val(combo[idx]))
        label_text = "/".join(label_lines)  # for logging only

        bb = oriented.BoundBox
        entries.append((oriented, label_lines))
        print(f"  {tag}  →  {label_text}  "
              f"({bb.XLength:.1f}×{bb.YLength:.1f}×{bb.ZLength:.1f})")

    if not entries:
        print("ERROR: No valid shapes were generated")
        close_project(doc, varset, orig_vals)
        sys.exit(1)

    # ── Compute grid layout ──────────────────────────────────────────────
    n = len(entries)
    max_bx = max(s.BoundBox.XLength for s, _ in entries)
    max_by = max(s.BoundBox.YLength for s, _ in entries)

    # Raft is circular: radius = sqrt((w/2+ext)^2 + (h/2+ext)^2)
    ext = REED_MATRIX_RAFT_EXTEND
    max_raft_d = 2.0 * math.sqrt((max_bx / 2.0 + ext) ** 2
                                  + (max_by / 2.0 + ext) ** 2)

    cell_x = max(max_bx, max_raft_d) + REED_MATRIX_SPACING
    cell_y = max(max_by, max_raft_d) + REED_MATRIX_SPACING

    bed_x = PRUSA_BED_X - 2.0 * PRUSA_BED_MARGIN
    bed_y = PRUSA_BED_Y - 2.0 * PRUSA_BED_MARGIN

    # Try both orientations (swap cell axes)
    best = None
    for swap in (False, True):
        cx, cy = (cell_y, cell_x) if swap else (cell_x, cell_y)
        max_cols = max(1, int(bed_x / cx))
        max_rows = max(1, int(bed_y / cy))
        if max_cols * max_rows < n:
            continue
        for cols in range(1, max_cols + 1):
            rows = math.ceil(n / cols)
            if rows > max_rows:
                continue
            total_w = cols * cx
            total_h = rows * cy
            area = total_w * total_h
            if best is None or area < best["area"]:
                best = {
                    "cols": cols, "rows": rows,
                    "cell_x": cx, "cell_y": cy,
                    "total_w": total_w, "total_h": total_h,
                    "swap": swap, "area": area,
                }

    if best is None:
        max_fit_no_swap = (max(1, int(bed_x / cell_x))
                           * max(1, int(bed_y / cell_y)))
        max_fit_swap = (max(1, int(bed_x / cell_y))
                        * max(1, int(bed_y / cell_x)))
        capacity = max(max_fit_no_swap, max_fit_swap)
        print(f"\nERROR: {n} reed variants do not fit the print area "
              f"({bed_x:.0f}×{bed_y:.0f} mm).  "
              f"Max capacity with {cell_x:.1f}×{cell_y:.1f} mm cells: "
              f"{capacity}")
        close_project(doc, varset, orig_vals)
        sys.exit(1)

    cols = best["cols"]
    rows = best["rows"]
    cx = best["cell_x"]
    cy = best["cell_y"]
    swap = best["swap"]

    print(f"\n  Grid: {cols}×{rows}  cell={cx:.1f}×{cy:.1f} mm  "
          f"total={best['total_w']:.1f}×{best['total_h']:.1f} mm"
          f"{'  (swapped)' if swap else ''}\n")

    # ── Place reeds and build labels ─────────────────────────────────────
    all_reed_solids = []
    all_label_solids = []

    for idx, (oriented, label_lines) in enumerate(entries):
        col = idx % cols
        row = idx // cols

        bb = oriented.BoundBox

        # Position: centre within cell, with spacing on each side
        if swap:
            face_w = bb.YLength
            face_h = bb.XLength
        else:
            face_w = bb.XLength
            face_h = bb.YLength

        gx = col * cx + (cx - bb.XLength) / 2.0
        gy = row * cy + (cy - bb.YLength) / 2.0

        placed = oriented.copy()
        placed.translate(FreeCAD.Vector(gx, gy, 0))
        all_reed_solids.append(placed)

        # Build a thin circular raft around the reed footprint at z=0
        ext = REED_MATRIX_RAFT_EXTEND
        raft_cx = gx + bb.XLength / 2.0
        raft_cy = gy + bb.YLength / 2.0
        raft_r = math.sqrt((bb.XLength / 2.0 + ext) ** 2
                           + (bb.YLength / 2.0 + ext) ** 2)
        raft = Part.makeCylinder(
            raft_r, REED_MATRIX_RAFT_THICKNESS,
            FreeCAD.Vector(raft_cx, raft_cy, 0),
            FreeCAD.Vector(0, 0, 1),
        )
        all_reed_solids.append(raft)

        # Build label on the raft circular area
        # Use bounding square of the circle for label layout
        lx = raft_cx - raft_r
        ly = raft_cy - raft_r
        lw = 2.0 * raft_r
        lh = 2.0 * raft_r

        glyph_solids = build_reed_labels(
            label_lines, lx, ly, lw, lh,
            REED_MATRIX_LABEL_DEPTH,
            REED_MATRIX_LABEL_MARGIN,
            font_dir, font_file,
        )
        if glyph_solids:
            all_label_solids.extend(glyph_solids)
        else:
            print(f"  WARN: label {label_lines} could not be created")

    # ── Export ────────────────────────────────────────────────────────────
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    if all_reed_solids:
        reed_compound = Part.makeCompound(all_reed_solids)
        reed_path = os.path.join(OUTPUT_DIR, REED_MATRIX_STL_NAME)
        nf = export_shape_stl(reed_compound, reed_path)
        print(f"  {REED_MATRIX_STL_NAME}  ({nf} facets, "
              f"{len(all_reed_solids)} reeds)")

    if all_label_solids:
        label_compound = Part.makeCompound(all_label_solids)
        label_path = os.path.join(OUTPUT_DIR, REED_MATRIX_LABEL_STL_NAME)
        nf = export_shape_stl(label_compound, label_path)
        print(f"  {REED_MATRIX_LABEL_STL_NAME}  ({nf} facets, "
              f"{len(all_label_solids)} glyphs)")

    close_project(doc, varset, orig_vals)
    print(f"\nDone. STL files written to: {OUTPUT_DIR}")


run()
