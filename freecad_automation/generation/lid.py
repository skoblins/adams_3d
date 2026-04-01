#!/usr/bin/env python3
"""Build and export pocket lid(s) with magnet pockets (listek or stroik).

Sweeps parameters to determine pocket layout, then builds a matching
lid (or two) and exports as STL.

Set BOX_MODE env var to 'listek' (default) or 'stroik' to select which body.

Usage:
    BOX_MODE=stroik freecadcmd -c "exec(open('.../lid.py').read())"
"""

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
    OUTPUT_DIR, LISTEK_RANGES, STROIK_RANGES,
    LISTEK_LID_THICKNESS, LISTEK_LID_LIP_HEIGHT, LISTEK_LID_LIP_INSET,
    LISTEK_BOX_OUTER_MARGIN, LISTEK_BOX_CELL_SPACING,
    LISTEK_MAGNET_DIAMETER, LISTEK_MAGNET_CORNER_INSET,
    LISTEK_LID_STL_NAME, LISTEK_LID_SPLIT_NAME_FMT,
    LISTEK_LID_TEXT_STL_NAME, LISTEK_LID_TEXT_SPLIT_NAME_FMT,
    LISTEK_LID_LABEL_DEPTH,
    LISTEK_BOX_MAX_X, LISTEK_BOX_MAX_Y,
    STROIK_LID_STL_NAME, STROIK_LID_SPLIT_NAME_FMT,
    STROIK_LID_TEXT_STL_NAME, STROIK_LID_TEXT_SPLIT_NAME_FMT,
)
from helpers import (
    export_shape_stl,
    open_project, close_project,
    collect_listek_pockets, collect_stroik_pockets,
    partition_listek_boxes,
    make_magnet_solids,
)

BOX_MODE = os.environ.get("BOX_MODE", "listek")


def _short_val(v):
    """Shortest format: 34.00→'34', 1.40→'1.4', 0.20→'0.2'."""
    s = f"{v:.2f}"
    if "." in s:
        s = s.rstrip("0")
        if s.endswith("."):
            s = s[:-1]
    return s


def _format_range_summary(ranges):
    """Format ranges dict into list of compact lines for lid label."""
    short_names = {
        "leaf_len": "L",
        "leaf_gap": "gap",
        "leaf_end_thickness": "et",
        "leaf_start_thickness": "st",
    }
    lines = []
    for param, (start, stop, step) in ranges.items():
        name = short_names.get(param, param)
        v, vals = start, []
        while v < stop - 1e-9:
            vals.append(round(v, 6))
            v += step
        if not vals:
            continue
        first_s = _short_val(vals[0])
        last_s = _short_val(vals[-1])
        step_s = _short_val(step)
        if first_s == last_s:
            lines.append(f"{name}={first_s}")
        else:
            lines.append(f"{name}={first_s}-{last_s}/{step_s}")
    return lines


def build_listek_lid(layout):
    """Build a plain lid with lip and magnet pockets (no text)."""
    width = layout["width"]
    height = layout["height"]

    lid_total_h = LISTEK_LID_THICKNESS + LISTEK_LID_LIP_HEIGHT

    # Outer slab
    lid = Part.makeBox(width, height, lid_total_h, FreeCAD.Vector(0, 0, 0))

    # Collect all solids to cut in one batch.
    cut_solids = []

    # 1) Lip recess: remove material around the lip so only the
    #    inner block remains as a downward-protruding lip.
    lip_inset = LISTEK_BOX_OUTER_MARGIN - LISTEK_LID_LIP_INSET
    lip_x = width - 2.0 * lip_inset
    lip_y = height - 2.0 * lip_inset
    if lip_x > 0 and lip_y > 0:
        outer_block = Part.makeBox(
            width, height, LISTEK_LID_LIP_HEIGHT,
            FreeCAD.Vector(0, 0, 0),
        )
        inner_block = Part.makeBox(
            lip_x, lip_y, LISTEK_LID_LIP_HEIGHT,
            FreeCAD.Vector(lip_inset, lip_inset, 0),
        )
        cut_solids.append(outer_block.cut(inner_block))

    # 2) Magnet pockets above the lip.
    cut_solids.extend(make_magnet_solids(width, height, LISTEK_LID_LIP_HEIGHT))

    # 3) Clearance holes in the lip for the box's magnets (from z=0 upward).
    r = LISTEK_MAGNET_DIAMETER / 2.0
    inset = LISTEK_MAGNET_CORNER_INSET
    corners = [
        (inset, inset),
        (width - inset, inset),
        (inset, height - inset),
        (width - inset, height - inset),
    ]
    for cx, cy in corners:
        cut_solids.append(Part.makeCylinder(
            r, LISTEK_LID_LIP_HEIGHT,
            FreeCAD.Vector(cx, cy, 0),
            FreeCAD.Vector(0, 0, 1),
        ))

    # Single boolean cut.
    lid = lid.cut(Part.makeCompound(cut_solids))

    return lid


def build_lid_text_modifier(layout, pocket_sizes, pocket_labels,
                            label_text_height=None, label_depth=None):
    """Build pocket labels as a separate solid for modifier-STL export.

    Each label is placed at the exact centre of its pocket cell (matching
    the pocket positions used by the box builder).  Text is auto-scaled to
    fit within the cell, rotated 90° when the cell is taller than wide, and
    X-mirrored so it reads correctly when viewed through the lid from above.

    Returns the fused text shape, or None if no labels could be built.
    """
    if not pocket_sizes or not pocket_labels or not any(pocket_labels):
        return None

    try:
        from config import LABEL_MACRO_PATH as _macro_path
        ns = {"__name__": "__label_face_headless__"}
        with open(_macro_path, "r", encoding="utf-8") as f:
            exec(compile(f.read(), _macro_path, "exec"), ns)
        find_font = ns["find_font"]
        make_planar_face = ns["make_planar_face"]
    except Exception as exc:
        print(f"  WARN: Could not load label helpers: {exc}")
        return None

    font_dir, font_file = find_font()
    if not font_dir:
        print("  WARN: No font found for pocket labels")
        return None

    width = layout["width"]
    cols = layout["cols"]
    cell_x = layout["cell_x"]
    cell_y = layout["cell_y"]
    swap = layout.get("swap", False)

    x0 = LISTEK_BOX_OUTER_MARGIN
    y0 = LISTEK_BOX_OUTER_MARGIN
    step_x = cell_x + LISTEK_BOX_CELL_SPACING
    step_y = cell_y + LISTEK_BOX_CELL_SPACING

    depth = label_depth or LISTEK_LID_LABEL_DEPTH
    margin = 0.5  # mm inset from cell edge

    label_solids = []
    for idx, lbl in enumerate(pocket_labels):
        if not lbl or idx >= len(pocket_sizes):
            continue
        sx_raw, sy_raw = pocket_sizes[idx]
        sx, sy = (sy_raw, sx_raw) if swap else (sx_raw, sy_raw)
        row = idx // cols
        col = (cols - 1) - (idx % cols)  # mirror columns for face-down printing

        # Pocket position — mirrored column order so labels match pockets
        # after the lid is flipped 180° for face-down printing
        px = x0 + col * step_x + (cell_x - sx) / 2.0
        py = y0 + row * step_y + (cell_y - sy) / 2.0

        # Available area for the label inside this pocket cell
        avail_x = sx - 2.0 * margin
        avail_y = sy - 2.0 * margin
        if avail_x <= 0 or avail_y <= 0:
            continue

        # Decide whether to rotate 90° (run text along the long axis)
        rotate = avail_y > avail_x
        if rotate:
            fit_w = avail_y  # text width  fits the long dimension
            fit_h = avail_x  # text height fits the short dimension
        else:
            fit_w = avail_x
            fit_h = avail_y

        # Auto-scale text height to fit within the cell
        text_h = fit_h * 0.7
        wires_per_char = None
        for _attempt in range(6):
            wires_per_char = Part.makeWireString(
                lbl, font_dir, font_file, text_h, 0.0)
            if not wires_per_char:
                break
            all_w = [w for cw in wires_per_char for w in cw]
            if not all_w:
                wires_per_char = None
                break
            bb = Part.makeCompound(all_w).BoundBox
            if bb.XLength <= fit_w and bb.YLength <= fit_h:
                break
            scale = min(fit_w / bb.XLength, fit_h / bb.YLength) * 0.95
            text_h *= scale
        else:
            pass  # proceed with whatever we have

        if not wires_per_char:
            continue

        all_w = [w for cw in wires_per_char for w in cw]
        if not all_w:
            continue
        bb = Part.makeCompound(all_w).BoundBox

        # Cell centre
        face_cx = px + sx / 2.0
        face_cy = py + sy / 2.0
        cx_text = bb.XMin + bb.XLength / 2.0
        cy_text = bb.YMin + bb.YLength / 2.0

        if rotate:
            # 90° CCW rotation + X-mirror so text reads correctly
            # when viewed from the lid top (through the material).
            #   input X → output Y,  input Y → output X (mirrored)
            tx = face_cx - cy_text
            ty = face_cy - cx_text
            mat = FreeCAD.Matrix(
                0, 1, 0, tx,
                1, 0, 0, ty,
                0, 0, 1, 0,
                0, 0, 0, 1,
            )
        else:
            # No rotation, X-mirror for readability through the lid.
            tx = face_cx + cx_text  # mirror: -(x - cx) + face_cx
            ty = face_cy - cy_text
            mat = FreeCAD.Matrix(
                -1, 0, 0, tx,
                 0, 1, 0, ty,
                 0, 0, 1, 0,
                 0, 0, 0, 1,
            )

        extrude_dir = FreeCAD.Vector(0, 0, depth)
        offset_vec = FreeCAD.Vector(0, 0, -0.01)

        for char_wires in wires_per_char:
            try:
                transformed = [w.transformGeometry(mat) for w in char_wires]
                for tw in transformed:
                    tw.translate(offset_vec)
                face_shape = make_planar_face(transformed)
                solid = face_shape.extrude(extrude_dir)
                label_solids.append(solid)
            except Exception:
                pass

    if not label_solids:
        return None

    if len(label_solids) == 1:
        return label_solids[0]

    text_shape = label_solids[0]
    for s in label_solids[1:]:
        text_shape = text_shape.fuse(s)
    return text_shape


def build_lid_summary(layout, ranges, label_depth, extra_lines=None):
    """Build a multi-line summary label on the lid top surface.

    Each parameter range gets its own line.  Lines are stacked vertically,
    auto-scaled to fit within the lid width and height, then centred on
    the top face.  Uses direct wire-string rendering with scaling instead
    of build_label_solid (which doesn't constrain to face bounds).

    *extra_lines* — optional list of pre-formatted strings appended after
    the range summary (e.g. ``["di=5.3"]``).
    """
    try:
        from config import LABEL_MACRO_PATH as _macro_path
        ns = {"__name__": "__label_face_headless__"}
        with open(_macro_path, "r", encoding="utf-8") as f:
            exec(compile(f.read(), _macro_path, "exec"), ns)
        find_font = ns["find_font"]
        make_planar_face = ns["make_planar_face"]
    except Exception as exc:
        print(f"  WARN: Could not load label helpers for summary: {exc}")
        return None

    font_dir, font_file = find_font()
    if not font_dir:
        print("  WARN: No font found for summary label")
        return None

    width = layout["width"]
    height = layout["height"]
    lines = _format_range_summary(ranges)
    if extra_lines:
        lines.extend(extra_lines)
    if not lines:
        return None

    lid_top_z = LISTEK_LID_THICKNESS + LISTEK_LID_LIP_HEIGHT

    # Orient text along the longest edge so it fits best.
    rotated = height > width
    if rotated:
        long_dim, short_dim = height, width
    else:
        long_dim, short_dim = width, height

    n_lines = len(lines)

    pad = 1.5
    line_gap = 0.8  # mm between lines
    face_w = long_dim - 2.0 * pad       # text flows along longest edge
    total_avail_h = short_dim - 2.0 * pad  # lines stack along short edge

    if face_w <= 0 or total_avail_h <= 0:
        return None

    # First pass: determine text height that fits all lines within the lid.
    # Start with height that fills the vertical space equally.
    max_line_h = (total_avail_h - (n_lines - 1) * line_gap) / n_lines
    text_h = max_line_h * 0.9

    # Measure each line's width and find the worst-case scale factor.
    for _attempt in range(8):
        max_width_ratio = 0.0
        for line_text in lines:
            wires = Part.makeWireString(
                line_text, font_dir, font_file, text_h, 0.0)
            if not wires:
                continue
            all_w = [w for cw in wires for w in cw]
            if all_w:
                bb = Part.makeCompound(all_w).BoundBox
                ratio = bb.XLength / face_w
                if ratio > max_width_ratio:
                    max_width_ratio = ratio
        if max_width_ratio <= 1.0:
            break
        text_h *= (1.0 / max_width_ratio) * 0.95
    else:
        # Even after scaling, proceed with whatever we have
        pass

    # Measure actual rendered height and scale down if lines don't fit
    # vertically.  Iterate until the total stacked height fits.
    for _v_attempt in range(5):
        line_bbs = []
        for line_text in lines:
            wires = Part.makeWireString(
                line_text, font_dir, font_file, text_h, 0.0)
            if not wires:
                line_bbs.append(None)
                continue
            all_w = [w for cw in wires for w in cw]
            if all_w:
                line_bbs.append(Part.makeCompound(all_w).BoundBox)
            else:
                line_bbs.append(None)

        max_rendered_h = max((b.YLength for b in line_bbs if b), default=text_h)
        actual_line_h = max_rendered_h * 1.1  # small extra clearance
        total_text_h = n_lines * actual_line_h + (n_lines - 1) * line_gap
        if total_text_h <= total_avail_h:
            break
        # Scale down proportionally to fit
        text_h *= (total_avail_h / total_text_h) * 0.95

    y_start = pad + (total_avail_h - total_text_h) / 2.0  # vertical centring

    extrude_dir = FreeCAD.Vector(0, 0, label_depth)
    offset_vec = FreeCAD.Vector(0, 0, -0.01)  # avoid coplanar issues

    # Build text in a virtual (long_dim × short_dim) space along X,
    # then rotate into place if the longest edge is along Y.
    all_solids = []
    for i, line_text in enumerate(lines):
        wires_per_char = Part.makeWireString(
            line_text, font_dir, font_file, text_h, 0.0)
        if not wires_per_char:
            continue
        all_w = [w for cw in wires_per_char for w in cw]
        if not all_w:
            continue
        bb = Part.makeCompound(all_w).BoundBox

        # Centre this line horizontally, stack vertically
        ly = y_start + i * (actual_line_h + line_gap)
        off_x = pad + (face_w - bb.XLength) / 2.0 - bb.XMin
        off_y = ly - bb.YMin

        for char_wires in wires_per_char:
            try:
                moved = []
                for w in char_wires:
                    w2 = w.copy()
                    w2.translate(FreeCAD.Vector(off_x, off_y, lid_top_z - label_depth))
                    w2.translate(offset_vec)
                    moved.append(w2)
                face_shape = make_planar_face(moved)
                solid = face_shape.extrude(extrude_dir)
                all_solids.append(solid)
            except Exception:
                pass

    if not all_solids:
        return None

    if len(all_solids) == 1:
        result = all_solids[0]
    else:
        result = all_solids[0]
        for s in all_solids[1:]:
            result = result.fuse(s)

    # Rotate the text block from the virtual space onto the actual lid.
    if rotated:
        vcx = long_dim / 2.0
        vcy = short_dim / 2.0
        result.rotate(FreeCAD.Vector(vcx, vcy, 0),
                      FreeCAD.Vector(0, 0, 1), 90)
        result.translate(FreeCAD.Vector(width / 2.0 - vcx,
                                        height / 2.0 - vcy, 0))

    return result


def run():
    doc, varset, stroik_body, listek_body = open_project()

    if BOX_MODE == "stroik":
        ranges = STROIK_RANGES
        body = stroik_body
        collect_fn = collect_stroik_pockets
        lid_stl = STROIK_LID_STL_NAME
        lid_split_fmt = STROIK_LID_SPLIT_NAME_FMT
        lid_text_stl = STROIK_LID_TEXT_STL_NAME
        lid_text_split_fmt = STROIK_LID_TEXT_SPLIT_NAME_FMT
        label = "stroik"
    else:
        ranges = LISTEK_RANGES
        body = listek_body
        collect_fn = collect_listek_pockets
        lid_stl = LISTEK_LID_STL_NAME
        lid_split_fmt = LISTEK_LID_SPLIT_NAME_FMT
        lid_text_stl = LISTEK_LID_TEXT_STL_NAME
        lid_text_split_fmt = LISTEK_LID_TEXT_SPLIT_NAME_FMT
        label = "listek"

    orig_vals = {p: getattr(varset, p) for p in ranges}

    pocket_sizes, pocket_labels = collect_fn(doc, varset, body)

    if not pocket_sizes:
        print("No valid pocket sizes collected")
        close_project(doc, varset, orig_vals)
        return

    print(f"\n=== Building {label} pocket lid with bed limit "
          f"{LISTEK_BOX_MAX_X:.1f}x{LISTEK_BOX_MAX_Y:.1f} mm ===\n")

    box_specs = partition_listek_boxes(pocket_sizes, pocket_labels)

    for i, (box_pockets, box_labels, layout) in enumerate(box_specs, start=1):
        lid_shape = build_listek_lid(layout)
        text_shape = build_lid_text_modifier(
            layout,
            pocket_sizes=box_pockets,
            pocket_labels=box_labels,
            label_depth=LISTEK_LID_LABEL_DEPTH,
        )
        d_inner_val = float(getattr(varset, "d_inner"))
        extra = [f"di={_short_val(d_inner_val)}"]
        summary_shape = build_lid_summary(layout, ranges, LISTEK_LID_LABEL_DEPTH,
                                          extra_lines=extra)
        if summary_shape is not None:
            if text_shape is not None:
                text_shape = text_shape.fuse(summary_shape)
            else:
                text_shape = summary_shape
            print(f"  Added summary label: {' | '.join(_format_range_summary(ranges))}")
        if len(box_specs) == 1:
            lid_name = lid_stl
            text_name = lid_text_stl
        else:
            lid_name = lid_split_fmt.format(index=i)
            text_name = lid_text_split_fmt.format(index=i)
        lid_path = os.path.join(OUTPUT_DIR, lid_name)
        n = export_shape_stl(lid_shape, lid_path)
        print(
            f"  {lid_name}  ({n} facets) "
            f"size={layout['width']:.1f}x{layout['height']:.1f} mm"
        )
        if text_shape is not None:
            text_path = os.path.join(OUTPUT_DIR, text_name)
            nt = export_shape_stl(text_shape, text_path)
            print(f"  {text_name}  ({nt} facets)  [text modifier]")

    close_project(doc, varset, orig_vals)
    print(f"\nDone. STL files written to: {OUTPUT_DIR}")


run()
