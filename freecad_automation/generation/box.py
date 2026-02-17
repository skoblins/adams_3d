#!/usr/bin/env python3
"""Build and export listek pocket box(es) with engraved labels and magnet pockets.

Sweeps listek parameters to determine pocket sizes, then builds a pocket tray
(or two if one exceeds bed limits) and exports as STL.

Usage:
    flatpak run --command=freecadcmd org.freecad.FreeCAD \\
        -c "exec(open('.../box.py').read())"
  or:
    ./box.sh
"""

import os
import sys
from concurrent.futures import ThreadPoolExecutor, as_completed

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
    LISTEK_POCKET_DEPTH, LISTEK_BOX_BOTTOM_THICKNESS,
    LISTEK_BOX_OUTER_MARGIN, LISTEK_BOX_CELL_SPACING,
    LISTEK_BOX_STL_NAME, LISTEK_BOX_SPLIT_NAME_FMT,
    LISTEK_BOX_LABEL_TEXT_HEIGHT, LISTEK_BOX_LABEL_DEPTH,
    LISTEK_MAGNET_DEPTH, LISTEK_LID_LIP_HEIGHT, LISTEK_LID_LIP_INSET,
    LISTEK_BOX_MAX_X, LISTEK_BOX_MAX_Y,
)
from helpers import (
    load_label_helpers, export_shape_stl,
    open_project, close_project,
    collect_listek_pockets, partition_listek_boxes,
    make_magnet_solids,
)


def build_listek_pocket_box(pocket_sizes, pocket_labels, layout,
                            build_label_solid=None, apply_label_to_shape=None):
    """Build a rectangular listek pocket tray with engraved pocket labels."""
    if not pocket_sizes:
        raise RuntimeError("No listek pocket sizes to build tray")
    if not layout:
        raise RuntimeError("No valid tray layout available")

    width = layout["width"]
    height = layout["height"]
    cols = layout["cols"]
    cell_x = layout["cell_x"]
    cell_y = layout["cell_y"]
    swap = layout["swap"]

    box_height = LISTEK_BOX_BOTTOM_THICKNESS + LISTEK_POCKET_DEPTH + LISTEK_LID_LIP_HEIGHT
    tray = Part.makeBox(width, height, box_height, FreeCAD.Vector(0, 0, 0))

    x0 = LISTEK_BOX_OUTER_MARGIN
    y0 = LISTEK_BOX_OUTER_MARGIN
    step_x = cell_x + LISTEK_BOX_CELL_SPACING
    step_y = cell_y + LISTEK_BOX_CELL_SPACING

    # Collect ALL solids to cut in one batch.
    cut_solids = []

    # 1) Lip recess: remove material from the top across the entire inner
    #    area so the lid lip can sit inside the outer rim.
    lip_recess_x = width - 2.0 * (LISTEK_BOX_OUTER_MARGIN - LISTEK_LID_LIP_INSET)
    lip_recess_y = height - 2.0 * (LISTEK_BOX_OUTER_MARGIN - LISTEK_LID_LIP_INSET)
    lip_recess_z = box_height - LISTEK_LID_LIP_HEIGHT
    if lip_recess_x > 0 and lip_recess_y > 0:
        cut_solids.append(Part.makeBox(
            lip_recess_x, lip_recess_y, LISTEK_LID_LIP_HEIGHT,
            FreeCAD.Vector(
                LISTEK_BOX_OUTER_MARGIN - LISTEK_LID_LIP_INSET,
                LISTEK_BOX_OUTER_MARGIN - LISTEK_LID_LIP_INSET,
                lip_recess_z,
            ),
        ))

    # 2) Individual pockets below the lip recess.
    pocket_z = LISTEK_BOX_BOTTOM_THICKNESS

    pocket_positions = []  # (px, py, sx, sy) for label engraving
    for i, (sx_raw, sy_raw) in enumerate(pocket_sizes):
        sx, sy = (sy_raw, sx_raw) if swap else (sx_raw, sy_raw)

        row = i // cols
        col = i % cols
        cell_min_x = x0 + col * step_x
        cell_min_y = y0 + row * step_y

        px = cell_min_x + (cell_x - sx) / 2.0
        py = cell_min_y + (cell_y - sy) / 2.0
        cut_solids.append(Part.makeBox(sx, sy, LISTEK_POCKET_DEPTH,
                                       FreeCAD.Vector(px, py, pocket_z)))
        pocket_positions.append((px, py, sx, sy))

    # 3) Magnet pockets at corners of box (from the top).
    box_mag_z = box_height - LISTEK_MAGNET_DEPTH
    cut_solids.extend(make_magnet_solids(width, height, box_mag_z))

    # Single boolean cut for lip + pockets + magnets.
    tray = tray.cut(Part.makeCompound(cut_solids))

    # Engrave parameter labels at each pocket bottom.
    # Labels are built per-pocket in parallel, then applied in one cut.
    if build_label_solid and apply_label_to_shape and pocket_labels:
        def _build_one_label(i, px, py, sx, sy, label_text):
            bottom_face = Part.makePlane(
                sx, sy,
                FreeCAD.Vector(px, py, pocket_z),
                FreeCAD.Vector(0, 0, 1),
            )
            return build_label_solid(
                label_text, bottom_face,
                LISTEK_BOX_LABEL_TEXT_HEIGHT, LISTEK_BOX_LABEL_DEPTH,
                False,
            )

        all_label_solids = []
        futures = {}
        with ThreadPoolExecutor() as pool:
            for i, (px, py, sx, sy) in enumerate(pocket_positions):
                if i >= len(pocket_labels) or not pocket_labels[i]:
                    continue
                fut = pool.submit(_build_one_label, i, px, py, sx, sy,
                                  pocket_labels[i])
                futures[fut] = i

            for fut in as_completed(futures):
                i = futures[fut]
                try:
                    label_solids = fut.result()
                    if isinstance(label_solids, (list, tuple)):
                        all_label_solids.extend(label_solids)
                    else:
                        all_label_solids.append(label_solids)
                except Exception as exc:
                    print(f"  WARN pocket {i+1} label failed: {exc}")

        if all_label_solids:
            tray = tray.cut(Part.makeCompound(all_label_solids))

    return tray


def run():
    doc, varset, _, listek_body = open_project()

    orig_vals = {p: getattr(varset, p) for p in LISTEK_RANGES}

    pocket_sizes, pocket_labels = collect_listek_pockets(doc, varset, listek_body)

    if not pocket_sizes:
        print("No valid pocket sizes collected")
        close_project(doc, varset, orig_vals)
        return

    # Load label helpers for pocket engraving
    build_label_solid = None
    apply_label_to_shape = None
    try:
        build_label_solid, apply_label_to_shape = load_label_helpers()
        print("Loaded label macro for pocket labels")
    except Exception as exc:
        print(f"WARN: Could not load label macro: {exc}")

    print(f"\n=== Building listek pocket box with bed limit "
          f"{LISTEK_BOX_MAX_X:.1f}x{LISTEK_BOX_MAX_Y:.1f} mm ===\n")

    box_specs = partition_listek_boxes(pocket_sizes, pocket_labels)

    def _build_one_box(i, box_pockets, box_labels, layout):
        """Build one box and export its STL. Returns status message."""
        box_shape = build_listek_pocket_box(
            box_pockets, box_labels, layout,
            build_label_solid, apply_label_to_shape,
        )
        if len(box_specs) == 1:
            stl_name = LISTEK_BOX_STL_NAME
        else:
            stl_name = LISTEK_BOX_SPLIT_NAME_FMT.format(index=i)
        box_path = os.path.join(OUTPUT_DIR, stl_name)
        n = export_shape_stl(box_shape, box_path)
        return (
            f"  {stl_name}  ({n} facets) "
            f"size={layout['width']:.1f}x{layout['height']:.1f} mm "
            f"pockets={len(box_pockets)}"
        )

    if len(box_specs) > 1:
        # Build multiple boxes in parallel threads.
        with ThreadPoolExecutor(max_workers=len(box_specs)) as pool:
            futures = {
                pool.submit(_build_one_box, i, bp, bl, lo): i
                for i, (bp, bl, lo) in enumerate(box_specs, start=1)
            }
            for fut in as_completed(futures):
                print(fut.result())
    else:
        bp, bl, lo = box_specs[0]
        print(_build_one_box(1, bp, bl, lo))

    close_project(doc, varset, orig_vals)
    print(f"\nDone. STL files written to: {OUTPUT_DIR}")


run()
