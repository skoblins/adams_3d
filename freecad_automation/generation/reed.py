#!/usr/bin/env python3
"""Export 'stroik' (reed) body STLs with parametric sweep over leaf_len × leaf_gap.

Usage:
    flatpak run --command=freecadcmd org.freecad.FreeCAD \\
        -c "exec(open('.../reed.py').read())"
  or:
    ./reed.sh
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

from config import (
    OUTPUT_DIR, STROIK_RANGES,
    ENABLE_STROIK_LABEL, STROIK_LABEL_VAR, STROIK_LABEL_FACE,
    STROIK_LABEL_TEXT_HEIGHT, STROIK_LABEL_DEPTH, STROIK_LABEL_EMBOSS,
)
from helpers import (
    frange, format_val, quantity_to_text,
    load_label_helpers, export_shape_stl,
    open_project, close_project,
)


def run():
    doc, varset, stroik_body, _ = open_project()

    build_label_solid = None
    apply_label_to_shape = None
    if ENABLE_STROIK_LABEL:
        try:
            build_label_solid, apply_label_to_shape = load_label_helpers()
            print(f"Loaded label macro, will engrave '{STROIK_LABEL_VAR}' "
                  f"on {STROIK_LABEL_FACE}")
        except Exception as exc:
            print(f"WARN: Could not load label macro: {exc}")

    orig_vals = {p: getattr(varset, p) for p in STROIK_RANGES}

    param_names = list(STROIK_RANGES.keys())
    param_values = [frange(*STROIK_RANGES[p]) for p in param_names]
    combos = list(itertools.product(*param_values))

    print(f"\n=== stroik: {len(combos)} combinations "
          f"({' x '.join(param_names)}) ===\n")

    for combo in combos:
        tag_parts = []
        for pname, pval in zip(param_names, combo):
            setattr(varset, pname, pval)
            tag_parts.append(f"{pname}={format_val(pval)}")
        doc.recompute()

        tag = "_".join(tag_parts)
        stl_name = f"stroik_{tag}.stl"
        stl_path = os.path.join(OUTPUT_DIR, stl_name)

        if not stroik_body.Shape.isValid():
            print(f"  SKIP {stl_name} — invalid shape")
            continue

        shape = stroik_body.Shape
        if ENABLE_STROIK_LABEL and build_label_solid and apply_label_to_shape:
            try:
                target_face = stroik_body.Shape.getElement(STROIK_LABEL_FACE)
                label_text = quantity_to_text(getattr(varset, STROIK_LABEL_VAR))
                label_solids = build_label_solid(
                    label_text, target_face,
                    STROIK_LABEL_TEXT_HEIGHT, STROIK_LABEL_DEPTH,
                    STROIK_LABEL_EMBOSS,
                )
                shape = apply_label_to_shape(
                    shape, label_solids, STROIK_LABEL_EMBOSS,
                )
            except Exception as exc:
                print(f"  WARN {stl_name} — labeling failed: {exc}")

        n = export_shape_stl(shape, stl_path)
        print(f"  {stl_name}  ({n} facets)")

    close_project(doc, varset, orig_vals)
    print(f"\nDone. STL files written to: {OUTPUT_DIR}")


run()
