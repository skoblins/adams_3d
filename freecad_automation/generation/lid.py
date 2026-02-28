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
    LISTEK_BOX_LABEL_TEXT_HEIGHT,
    STROIK_LID_STL_NAME, STROIK_LID_SPLIT_NAME_FMT,
    STROIK_LID_TEXT_STL_NAME, STROIK_LID_TEXT_SPLIT_NAME_FMT,
    STROIK_BOX_LABEL_TEXT_HEIGHT,
)
from helpers import (
    export_shape_stl,
    open_project, close_project,
    collect_listek_pockets, collect_stroik_pockets,
    partition_listek_boxes,
    make_magnet_solids,
    load_label_helpers,
)

BOX_MODE = os.environ.get("BOX_MODE", "listek")


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
    """Build mirrored pocket labels as a separate solid for modifier-STL export.

    The solid is positioned on the lid bottom so it can be loaded alongside
    the lid in the slicer and used as a filament-change modifier object.
    Returns the fused text shape, or None if no labels could be built.
    """
    if not pocket_sizes or not pocket_labels or not any(pocket_labels):
        return None

    try:
        build_label_solid, _ = load_label_helpers()
    except Exception as exc:
        print(f"  WARN: Could not load label helpers: {exc}")
        return None

    if not build_label_solid:
        return None

    width = layout["width"]
    height = layout["height"]
    cols = layout["cols"]
    cell_x = layout["cell_x"]
    cell_y = layout["cell_y"]
    swap = layout.get("swap", False)

    x0 = LISTEK_BOX_OUTER_MARGIN
    y0 = LISTEK_BOX_OUTER_MARGIN
    step_x = cell_x + LISTEK_BOX_CELL_SPACING
    step_y = cell_y + LISTEK_BOX_CELL_SPACING

    text_h = label_text_height or LISTEK_BOX_LABEL_TEXT_HEIGHT
    depth = label_depth or LISTEK_LID_LABEL_DEPTH

    label_solids = []
    for idx, lbl in enumerate(pocket_labels):
        if not lbl or idx >= len(pocket_sizes):
            continue
        sx_raw, sy_raw = pocket_sizes[idx]
        sx, sy = (sy_raw, sx_raw) if swap else (sx_raw, sy_raw)
        row = idx // cols
        col = idx % cols
        px = x0 + col * step_x + (cell_x - sx) / 2.0
        py = y0 + row * step_y + (cell_y - sy) / 2.0

        face = Part.makePlane(
            sx, sy,
            FreeCAD.Vector(px, py, 0),
            FreeCAD.Vector(0, 0, 1),
        )
        try:
            solids = build_label_solid(
                lbl, face, text_h, depth, emboss=True)
            if not isinstance(solids, (list, tuple)):
                solids = [solids]
            for s in solids:
                mirrored = s.mirror(
                    FreeCAD.Vector(width / 2.0, 0, 0),
                    FreeCAD.Vector(1, 0, 0),
                )
                label_solids.append(mirrored)
        except Exception as exc:
            print(f"  WARN lid label '{lbl}': {exc}")

    if not label_solids:
        return None

    if len(label_solids) == 1:
        return label_solids[0]

    text_shape = label_solids[0]
    for s in label_solids[1:]:
        text_shape = text_shape.fuse(s)
    return text_shape


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

    if BOX_MODE == "stroik":
        lid_label_text_height = STROIK_BOX_LABEL_TEXT_HEIGHT
    else:
        lid_label_text_height = LISTEK_BOX_LABEL_TEXT_HEIGHT

    for i, (box_pockets, box_labels, layout) in enumerate(box_specs, start=1):
        lid_shape = build_listek_lid(layout)
        text_shape = build_lid_text_modifier(
            layout,
            pocket_sizes=box_pockets,
            pocket_labels=box_labels,
            label_text_height=lid_label_text_height,
            label_depth=LISTEK_LID_LABEL_DEPTH,
        )
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
