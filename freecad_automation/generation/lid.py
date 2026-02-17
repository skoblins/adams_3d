#!/usr/bin/env python3
"""Build and export listek pocket lid(s) with magnet pockets.

Sweeps listek parameters to determine pocket layout, then builds a matching
lid (or two) and exports as STL.

Usage:
    flatpak run --command=freecadcmd org.freecad.FreeCAD \\
        -c "exec(open('.../lid.py').read())"
  or:
    ./lid.sh
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
    OUTPUT_DIR, LISTEK_RANGES,
    LISTEK_LID_THICKNESS, LISTEK_LID_LIP_HEIGHT, LISTEK_LID_LIP_INSET,
    LISTEK_BOX_OUTER_MARGIN,
    LISTEK_MAGNET_DIAMETER, LISTEK_MAGNET_CORNER_INSET,
    LISTEK_LID_STL_NAME, LISTEK_LID_SPLIT_NAME_FMT,
    LISTEK_BOX_MAX_X, LISTEK_BOX_MAX_Y,
)
from helpers import (
    export_shape_stl,
    open_project, close_project,
    collect_listek_pockets, partition_listek_boxes,
    make_magnet_solids,
)


def build_listek_lid(layout):
    """Build a lid that sits on top of the pocket box with matching magnet pockets."""
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


def run():
    doc, varset, _, listek_body = open_project()

    orig_vals = {p: getattr(varset, p) for p in LISTEK_RANGES}

    pocket_sizes, pocket_labels = collect_listek_pockets(doc, varset, listek_body)

    if not pocket_sizes:
        print("No valid pocket sizes collected")
        close_project(doc, varset, orig_vals)
        return

    print(f"\n=== Building listek pocket lid with bed limit "
          f"{LISTEK_BOX_MAX_X:.1f}x{LISTEK_BOX_MAX_Y:.1f} mm ===\n")

    box_specs = partition_listek_boxes(pocket_sizes, pocket_labels)

    for i, (_, _, layout) in enumerate(box_specs, start=1):
        lid_shape = build_listek_lid(layout)
        if len(box_specs) == 1:
            lid_name = LISTEK_LID_STL_NAME
        else:
            lid_name = LISTEK_LID_SPLIT_NAME_FMT.format(index=i)
        lid_path = os.path.join(OUTPUT_DIR, lid_name)
        n = export_shape_stl(lid_shape, lid_path)
        print(
            f"  {lid_name}  ({n} facets) "
            f"size={layout['width']:.1f}x{layout['height']:.1f} mm"
        )

    close_project(doc, varset, orig_vals)
    print(f"\nDone. STL files written to: {OUTPUT_DIR}")


run()
