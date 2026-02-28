#!/usr/bin/env python3
"""Prepare row-strip build args for a pocket box (listek or stroik).

Opens the FreeCAD project, sweeps parameters, computes pocket layout,
and writes one pickle file per row plus a JSON manifest.  The manifest tells
the shell script how many row workers to spawn and where to find the files.

Set BOX_MODE env var to 'listek' (default) or 'stroik' to select which body.

Usage (called by generate.sh, not directly):
    BOX_MODE=stroik freecadcmd -c "exec(open('box_prepare.py').read())"

Outputs:
    <tmp_dir>/manifest.json
    <tmp_dir>/box<B>_row<R>_args.pkl
"""

import json
import os
import pickle
import sys
import tempfile

try:
    _SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
except NameError:
    _SCRIPT_DIR = "/home/adam/adams_3d/freecad_automation/generation"
if _SCRIPT_DIR not in sys.path:
    sys.path.insert(0, _SCRIPT_DIR)

import FreeCAD  # noqa: F401 — needed for project open

from config import (
    OUTPUT_DIR, LISTEK_RANGES, STROIK_RANGES,
    LISTEK_POCKET_DEPTH, LISTEK_BOX_BOTTOM_THICKNESS,
    LISTEK_BOX_OUTER_MARGIN, LISTEK_BOX_CELL_SPACING,
    LISTEK_BOX_STL_NAME, LISTEK_BOX_SPLIT_NAME_FMT,
    LISTEK_MAGNET_DIAMETER, LISTEK_MAGNET_DEPTH, LISTEK_MAGNET_CORNER_INSET,
    LISTEK_LID_LIP_HEIGHT, LISTEK_LID_LIP_INSET,
    LISTEK_BOX_MAX_X, LISTEK_BOX_MAX_Y,
    STROIK_BOX_STL_NAME, STROIK_BOX_SPLIT_NAME_FMT,
    STROIK_POCKET_DEPTH_FACTOR,
)
from helpers import (
    open_project, close_project,
    collect_listek_pockets, collect_stroik_pockets,
    partition_listek_boxes,
)

BOX_MODE = os.environ.get("BOX_MODE", "listek")


def _prepare_box_rows(pocket_sizes, pocket_labels, layout, box_index, tmp_dir,
                      pocket_depth):
    """Compute row-strip args for one tray and write pickle files.

    Returns a list of dicts (one per row) with keys:
        args_file, brep_file, y_start, y_end, pocket_count
    """
    width = layout["width"]
    height = layout["height"]
    cols = layout["cols"]
    rows_count = layout["rows"]
    cell_x = layout["cell_x"]
    cell_y = layout["cell_y"]
    swap = layout["swap"]

    box_height = (LISTEK_BOX_BOTTOM_THICKNESS + pocket_depth
                  + LISTEK_LID_LIP_HEIGHT)
    pocket_z = LISTEK_BOX_BOTTOM_THICKNESS

    x0 = LISTEK_BOX_OUTER_MARGIN
    y0 = LISTEK_BOX_OUTER_MARGIN
    step_x = cell_x + LISTEK_BOX_CELL_SPACING
    step_y = cell_y + LISTEK_BOX_CELL_SPACING

    # --- Lip recess data (global rectangle) ---
    lip_inset = LISTEK_BOX_OUTER_MARGIN - LISTEK_LID_LIP_INSET
    lip_rx = width - 2.0 * lip_inset
    lip_data = None
    if lip_rx > 0 and height - 2.0 * lip_inset > 0:
        lip_data = (
            lip_inset,
            lip_inset,
            height - lip_inset,
            box_height - LISTEK_LID_LIP_HEIGHT,
            lip_rx,
            LISTEK_LID_LIP_HEIGHT,
        )

    # --- Group pockets and labels by row ---
    row_pockets = [[] for _ in range(rows_count)]
    row_labels_g = [[] for _ in range(rows_count)]
    for i, (sx_raw, sy_raw) in enumerate(pocket_sizes):
        sx, sy = (sy_raw, sx_raw) if swap else (sx_raw, sy_raw)
        row = i // cols
        col = i % cols
        px = x0 + col * step_x + (cell_x - sx) / 2.0
        py = y0 + row * step_y + (cell_y - sy) / 2.0
        row_pockets[row].append((px, py, sx, sy))
        lbl = pocket_labels[i] if i < len(pocket_labels) else ""
        row_labels_g[row].append(lbl)

    # --- Row boundaries ---
    row_bounds = []
    for r in range(rows_count):
        y_start = (0.0 if r == 0
                   else y0 + r * step_y - LISTEK_BOX_CELL_SPACING / 2.0)
        y_end = (height if r == rows_count - 1
                 else y0 + (r + 1) * step_y - LISTEK_BOX_CELL_SPACING / 2.0)
        row_bounds.append((y_start, y_end))

    # --- Assign corner magnets to rows ---
    r_mag = LISTEK_MAGNET_DIAMETER / 2.0
    box_mag_z = box_height - LISTEK_MAGNET_DEPTH
    all_magnets = [
        (LISTEK_MAGNET_CORNER_INSET, LISTEK_MAGNET_CORNER_INSET,
         r_mag, LISTEK_MAGNET_DEPTH, box_mag_z),
        (width - LISTEK_MAGNET_CORNER_INSET, LISTEK_MAGNET_CORNER_INSET,
         r_mag, LISTEK_MAGNET_DEPTH, box_mag_z),
        (LISTEK_MAGNET_CORNER_INSET, height - LISTEK_MAGNET_CORNER_INSET,
         r_mag, LISTEK_MAGNET_DEPTH, box_mag_z),
        (width - LISTEK_MAGNET_CORNER_INSET,
         height - LISTEK_MAGNET_CORNER_INSET,
         r_mag, LISTEK_MAGNET_DEPTH, box_mag_z),
    ]
    row_magnets = [[] for _ in range(rows_count)]
    for mag in all_magnets:
        cy = mag[1]
        for r, (ys, ye) in enumerate(row_bounds):
            if ys - 1e-9 <= cy <= ye + 1e-9:
                row_magnets[r].append(mag)
                break

    # --- Write pickle per row ---
    row_info = []
    for r in range(rows_count):
        ys, ye = row_bounds[r]
        args = (
            width, ys, ye, box_height,
            pocket_z, pocket_depth,
            lip_data,
            row_pockets[r],
            row_magnets[r],
        )
        args_file = os.path.join(tmp_dir, f"box{box_index}_row{r}_args.pkl")
        stl_file = os.path.join(tmp_dir, f"box{box_index}_row{r}.stl")
        with open(args_file, "wb") as f:
            pickle.dump(args, f)
        row_info.append({
            "args_file": args_file,
            "stl_file": stl_file,
            "y_start": ys,
            "y_end": ye,
            "pocket_count": len(row_pockets[r]),
        })

    return row_info


def run():
    doc, varset, stroik_body, listek_body = open_project()

    if BOX_MODE == "stroik":
        ranges = STROIK_RANGES
        body = stroik_body
        collect_fn = collect_stroik_pockets
        stl_name = STROIK_BOX_STL_NAME
        split_fmt = STROIK_BOX_SPLIT_NAME_FMT
        prefix = "stroik_box_"
        label = "stroik"
        # Pocket depth from reed diameter: d_outer is a radius
        d_outer_val = float(getattr(varset, "d_outer"))
        pocket_depth = d_outer_val * 2.0 * STROIK_POCKET_DEPTH_FACTOR
        print(f"  Reed pocket depth: d_outer={d_outer_val:.2f} (radius) "
              f"→ diameter={d_outer_val*2:.2f} → depth={pocket_depth:.2f} mm")
    else:
        ranges = LISTEK_RANGES
        body = listek_body
        collect_fn = collect_listek_pockets
        stl_name = LISTEK_BOX_STL_NAME
        split_fmt = LISTEK_BOX_SPLIT_NAME_FMT
        prefix = "listek_box_"
        label = "listek"
        pocket_depth = LISTEK_POCKET_DEPTH

    orig_vals = {p: getattr(varset, p) for p in ranges}

    pocket_sizes, pocket_labels = collect_fn(doc, varset, body)

    if not pocket_sizes:
        print("No valid pocket sizes collected")
        close_project(doc, varset, orig_vals)
        sys.exit(1)

    print(f"\n=== Preparing {label} pocket box (bed limit "
          f"{LISTEK_BOX_MAX_X:.1f}x{LISTEK_BOX_MAX_Y:.1f} mm) ===\n")

    box_specs = partition_listek_boxes(pocket_sizes, pocket_labels)

    tmp_dir = tempfile.mkdtemp(prefix=prefix, dir=_SCRIPT_DIR)
    manifest = {
        "tmp_dir": tmp_dir,
        "output_dir": OUTPUT_DIR,
        "boxes": [],
    }

    for bi, (box_pockets, box_labels, layout) in enumerate(box_specs):
        if len(box_specs) == 1:
            name = stl_name
        else:
            name = split_fmt.format(index=bi + 1)

        row_info = _prepare_box_rows(
            box_pockets, box_labels, layout, bi, tmp_dir, pocket_depth)

        manifest["boxes"].append({
            "stl_name": name,
            "width": layout["width"],
            "height": layout["height"],
            "pocket_count": len(box_pockets),
            "rows": row_info,
        })
        print(f"  Box {bi}: {name}  "
              f"size={layout['width']:.1f}x{layout['height']:.1f}  "
              f"pockets={len(box_pockets)}  rows={len(row_info)}")

    manifest_path = os.path.join(tmp_dir, "manifest.json")
    with open(manifest_path, "w") as f:
        json.dump(manifest, f, indent=2)

    close_project(doc, varset, orig_vals)

    # Print the manifest path on the last line — generate.sh reads this.
    print(f"MANIFEST={manifest_path}")


run()
