#!/usr/bin/env python3
"""Export listek (leaf) bodies in a print-ready matrix with text modifier labels.

Generates two STL files:
  - leaf_matrix.stl        — all leaf variants arranged in a grid
  - leaf_matrix_labels.stl — text labels (slicer modifier, different material)

Each leaf is oriented to lie on its bottom face
(Body001.Chamfer002.Face2) and arranged in a grid that fits the Prusa
print area.  Labels show parameter values in the shortest possible form
and are positioned flush with each leaf's bottom face so that after
loading into the slicer both files are immediately ready for slicing.

Usage:
    flatpak run --command=freecadcmd org.freecad.FreeCAD \\
        -c "exec(open('.../leaf_matrix.py').read())"
  or:
    ./generate.sh leaf_matrix
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
    OUTPUT_DIR, LISTEK_RANGES, LINEAR_DEFLECTION,
    PRUSA_BED_X, PRUSA_BED_Y, PRUSA_BED_MARGIN,
    LEAF_MATRIX_BOTTOM_FACE_FEATURE,
    LEAF_MATRIX_BOTTOM_FACE,
    LEAF_MATRIX_SPACING,
    LEAF_MATRIX_LABEL_DEPTH,
    LEAF_MATRIX_LABEL_MARGIN,
    LEAF_MATRIX_STL_NAME,
    LEAF_MATRIX_LABEL_STL_NAME,
    LEAF_MATRIX_LABEL_PARAMS,
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
    # Strip trailing zeros after decimal, keep at least one digit
    if "." in s:
        s = s.rstrip("0")
        if s.endswith("."):
            s = s[:-1]
    return s


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


def build_leaf_labels(text, x, y, face_w, face_h, depth, margin,
                      font_dir, font_file):
    """Build text-label solids for one leaf at grid position (x, y).

    The label sits on the Z=0 plane and extrudes *upward* by *depth*
    so it overlaps with the bottom of the leaf.  The text is rotated 90°
    to run along the long axis of the leaf for maximum readability, then
    mirrored so it reads correctly when viewing the bottom of the printed
    part.

    Returns a list of Part.Shape solids (one per glyph).
    """
    avail_w = face_w - 2.0 * margin
    avail_h = face_h - 2.0 * margin
    if avail_w <= 0 or avail_h <= 0:
        return []

    # Text will be rotated 90° so it runs along the long axis.
    # Fit text into: width → face_h (long), height → face_w (short).
    fit_w = avail_h   # text width  fits the long dimension
    fit_h = avail_w   # text height fits the short dimension

    # Start with text height = 70 % of available short dimension
    text_height = fit_h * 0.7

    for _attempt in range(5):
        wires_per_char = Part.makeWireString(
            text, font_dir, font_file, text_height, 0.0)
        if not wires_per_char:
            return []

        all_wires = [w for cw in wires_per_char for w in cw]
        if not all_wires:
            return []

        bb = Part.makeCompound(all_wires).BoundBox
        if bb.XLength <= fit_w and bb.YLength <= fit_h:
            break
        # Scale down uniformly to fit
        scale = min(fit_w / bb.XLength, fit_h / bb.YLength) * 0.95
        text_height *= scale
    else:
        return []  # could not fit even after scaling

    # Recompute bb after possible re-creation
    all_wires = [w for cw in wires_per_char for w in cw]
    bb = Part.makeCompound(all_wires).BoundBox

    # Build a 4x4 transform matrix that:
    #   1. Centres text at the origin
    #   2. Rotates 90° CCW  (X→-Y, Y→X  for the text baseline)
    #   3. Mirrors in the new-X direction (so text reads correctly from
    #      below the print bed)
    #   4. Translates to the centre of the leaf footprint
    #
    # Combining rotation 90° CCW  with X-mirror gives:
    #   x' = -(y - cy_text)  then mirror →  (y - cy_text)   + tx
    #   y' =  (x - cx_text)                                  + ty
    #
    # So the matrix columns are:
    #     col0 (maps input X):  ( 0,  1, 0)
    #     col1 (maps input Y):  ( 1,  0, 0)   (mirror flips the sign)
    #     col2 (maps input Z):  ( 0,  0, 1)
    #     col3 (translation)
    cx_text = bb.XMin + bb.XLength / 2.0
    cy_text = bb.YMin + bb.YLength / 2.0
    face_cx = x + face_w / 2.0
    face_cy = y + face_h / 2.0

    tx = face_cx - cy_text   # ← y_text maps to final x
    ty = face_cy - cx_text   # ← x_text maps to final y

    mat = FreeCAD.Matrix(
        0, 1, 0, tx,
        1, 0, 0, ty,
        0, 0, 1, 0,
        0, 0, 0, 1,
    )

    extrude_dir = FreeCAD.Vector(0, 0, depth)
    solids = []
    for char_wires in wires_per_char:
        try:
            transformed = [w.transformGeometry(mat) for w in char_wires]
            face_shape = _make_planar_face(transformed)
            solid = face_shape.extrude(extrude_dir)
            solids.append(solid)
        except Exception:
            pass

    return solids


# ── Main ─────────────────────────────────────────────────────────────────


def run():
    doc, varset, _, listek_body = open_project()

    font_dir, font_file = _find_font()
    if not font_dir:
        print("ERROR: No TrueType font found for labels")
        sys.exit(1)
    print(f"Font: {font_dir}{font_file}")

    orig_vals = {p: getattr(varset, p) for p in LISTEK_RANGES}

    param_names = list(LISTEK_RANGES.keys())
    param_values = [frange(*LISTEK_RANGES[p]) for p in param_names]
    combos = list(itertools.product(*param_values))

    print(f"\n=== leaf matrix: {len(combos)} combinations "
          f"({' x '.join(param_names)}) ===\n")

    # Feature that owns the bottom face
    face_feature = doc.getObject(LEAF_MATRIX_BOTTOM_FACE_FEATURE)
    if face_feature is None:
        print(f"WARN: Feature '{LEAF_MATRIX_BOTTOM_FACE_FEATURE}' not found, "
              f"falling back to Body001 for face lookup")

    # ── Collect oriented shapes ──────────────────────────────────────
    entries = []  # list of (oriented_shape, label_text)

    for combo in combos:
        for pname, pval in zip(param_names, combo):
            setattr(varset, pname, pval)
        doc.recompute()

        tag = "_".join(f"{pn}={format_val(pv)}"
                       for pn, pv in zip(param_names, combo))

        if not listek_body.Shape.isValid():
            print(f"  SKIP {tag} — invalid shape")
            continue

        # Get the bottom face from the feature (or body fallback)
        try:
            src = face_feature if face_feature else listek_body
            bottom_face = src.Shape.getElement(LEAF_MATRIX_BOTTOM_FACE)
        except Exception as exc:
            print(f"  SKIP {tag} — cannot find {LEAF_MATRIX_BOTTOM_FACE}: {exc}")
            continue

        oriented = orient_shape_on_face(listek_body.Shape, bottom_face)

        # Label text: shortest form of the configured parameters
        label_parts = []
        for p in LEAF_MATRIX_LABEL_PARAMS:
            if p in param_names:
                idx = param_names.index(p)
                label_parts.append(_short_val(combo[idx]))
        label_text = "/".join(label_parts)

        bb = oriented.BoundBox
        entries.append((oriented, label_text))
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

    cell_x = max_bx + LEAF_MATRIX_SPACING
    cell_y = max_by + LEAF_MATRIX_SPACING

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
        print(f"\nERROR: {n} leaf variants do not fit the print area "
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

    # ── Place leafs and build labels ─────────────────────────────────────
    all_leaf_solids = []
    all_label_solids = []

    for idx, (oriented, label_text) in enumerate(entries):
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
        all_leaf_solids.append(placed)

        # Build label at the leaf's XY footprint on Z=0
        lx = gx  # label origin x
        ly = gy  # label origin y
        lw = bb.XLength
        lh = bb.YLength

        glyph_solids = build_leaf_labels(
            label_text, lx, ly, lw, lh,
            LEAF_MATRIX_LABEL_DEPTH,
            LEAF_MATRIX_LABEL_MARGIN,
            font_dir, font_file,
        )
        if glyph_solids:
            all_label_solids.extend(glyph_solids)
        else:
            print(f"  WARN: label '{label_text}' could not be created")

    # ── Export ────────────────────────────────────────────────────────────
    os.makedirs(OUTPUT_DIR, exist_ok=True)

    if all_leaf_solids:
        leaf_compound = Part.makeCompound(all_leaf_solids)
        leaf_path = os.path.join(OUTPUT_DIR, LEAF_MATRIX_STL_NAME)
        nf = export_shape_stl(leaf_compound, leaf_path)
        print(f"  {LEAF_MATRIX_STL_NAME}  ({nf} facets, "
              f"{len(all_leaf_solids)} leafs)")

    if all_label_solids:
        label_compound = Part.makeCompound(all_label_solids)
        label_path = os.path.join(OUTPUT_DIR, LEAF_MATRIX_LABEL_STL_NAME)
        nf = export_shape_stl(label_compound, label_path)
        print(f"  {LEAF_MATRIX_LABEL_STL_NAME}  ({nf} facets, "
              f"{len(all_label_solids)} glyphs)")

    close_project(doc, varset, orig_vals)
    print(f"\nDone. STL files written to: {OUTPUT_DIR}")


run()
