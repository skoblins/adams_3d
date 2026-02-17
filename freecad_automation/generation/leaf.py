#!/usr/bin/env python3
"""Export 'listek' (leaf) body STLs with parametric sweep.

Usage:
    flatpak run --command=freecadcmd org.freecad.FreeCAD \\
        -c "exec(open('.../leaf.py').read())"
  or:
    ./leaf.sh
"""

import itertools
import os
import sys

try:
    _SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
except NameError:
    _SCRIPT_DIR = "/home/adam/adams_3d/freecad_automation/generation"
if _SCRIPT_DIR not in sys.path:
    sys.path.insert(0, _SCRIPT_DIR)

import FreeCAD

from config import OUTPUT_DIR, LISTEK_RANGES
from helpers import (
    frange, format_val, export_shape_stl,
    open_project, close_project,
)


def run():
    doc, varset, _, listek_body = open_project()

    orig_vals = {p: getattr(varset, p) for p in LISTEK_RANGES}

    param_names = list(LISTEK_RANGES.keys())
    param_values = [frange(*LISTEK_RANGES[p]) for p in param_names]
    combos = list(itertools.product(*param_values))

    print(f"\n=== listek: {len(combos)} combinations "
          f"({' x '.join(param_names)}) ===\n")

    for combo in combos:
        tag_parts = []
        for pname, pval in zip(param_names, combo):
            setattr(varset, pname, pval)
            tag_parts.append(f"{pname}={format_val(pval)}")
        doc.recompute()

        tag = "_".join(tag_parts)
        stl_name = f"listek_{tag}.stl"
        stl_path = os.path.join(OUTPUT_DIR, stl_name)

        if not listek_body.Shape.isValid():
            print(f"  SKIP {stl_name} — invalid shape")
            continue

        n = export_shape_stl(listek_body.Shape, stl_path)
        print(f"  {stl_name}  ({n} facets)")

    close_project(doc, varset, orig_vals)
    print(f"\nDone. STL files written to: {OUTPUT_DIR}")


run()
