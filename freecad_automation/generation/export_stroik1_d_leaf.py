#!/usr/bin/env python3
"""
Export STL files from stroik1-D-leaf_PLA_flexi-sealing.FCStd with parametric sweeps.

The script opens the project, reads VarSet defaults, then exports:
  - "stroik" body: one STL per (leaf_len, leaf_gap) combination
  - "listek" body: one STL per (leaf_end_thickness, leaf_start_thickness, leaf_len) combination

Each parameter range is specified as (start, stop, step) — stop is exclusive,
floats are supported (like numpy arange).

Usage:
    flatpak run --command=freecadcmd org.freecad.FreeCAD \\
        -c "exec(open('.../export_stroik1_d_leaf.py').read())"
  or via the companion shell wrapper:
    ./export_stroik1_d_leaf.sh

VarSet defaults (from the .FCStd project):
    d_inner             = 5.30 mm   (App::PropertyLength)
    d_outer             = 6.00 mm   (App::PropertyLength)
    d_outer_plug        = 6.05 mm   (App::PropertyDistance)
    leaf_end_thickness  = 0.19 mm   (App::PropertyDistance)
    leaf_gap            = 1.85 mm   (App::PropertyDistance)
    leaf_len            = 35.50 mm  (App::PropertyLength)
    leaf_start_thickness= 1.42 mm   (App::PropertyDistance)
    plug_inner_start    = 4.00 mm   (App::PropertyDistance)
    plug_len            = 15.00 mm  (App::PropertyDistance)
    plug_outer_start    = 4.40 mm   (App::PropertyDistance)
"""

import itertools
import os
import sys

import FreeCAD
import Mesh

# --- Path setup --------------------------------------------------------------
try:
    _SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
except NameError:
    _SCRIPT_DIR = "/home/adam/adams_3d/freecad_automation/generation"

PROJECT_PATH = os.path.normpath(
    os.path.join(_SCRIPT_DIR, "..", "..", "stroik",
                 "stroik1-D-leaf_PLA_flexi-sealing.FCStd")
)

LABEL_MACRO_PATH = os.path.normpath(
    os.path.join(_SCRIPT_DIR, "..", "label", "label_face.FCMacro")
)

OUTPUT_DIR = os.path.join(_SCRIPT_DIR, "output")

# --- Mesh quality -------------------------------------------------------------
LINEAR_DEFLECTION = 0.1   # mm  (smaller = finer mesh)

# --- Stroik labeling ----------------------------------------------------------
ENABLE_STROIK_LABEL = True
STROIK_LABEL_VAR = "leaf_gap"
STROIK_LABEL_FACE = "Face11"  # from: stroik1_D_leaf_PLA_flexi_sealing.Body.Pocket008.Face11
STROIK_LABEL_TEXT_HEIGHT = 3.0
STROIK_LABEL_DEPTH = 0.3
STROIK_LABEL_EMBOSS = False

# --- Parameter sweep ranges ---------------------------------------------------
# Each range is (start, stop, step) — stop is EXCLUSIVE, like Python's range()
# but supports floats.  A single-value "range" looks like (val, val+step, step).
#
# "stroik" body — sweep over leaf_len × leaf_gap
STROIK_RANGES = {
    "leaf_len":  (35.0, 36.5, 0.5),   # mm — 35.0, 35.5, 36.0
    "leaf_gap":  (1.75, 2.0, 0.05),   # mm — 1.75, 1.80, 1.85, 1.90, 1.95
}

# "listek" body — sweep over leaf_end_thickness × leaf_start_thickness × leaf_len
LISTEK_RANGES = {
    "leaf_end_thickness":   (0.16, 0.24, 0.02),  # mm
    "leaf_start_thickness": (1.36, 1.46, 0.02),  # mm
    "leaf_len":             (35.0, 36.5, 0.5),    # mm
}


# --- Helpers ------------------------------------------------------------------

def frange(start, stop, step):
    """Like range() but for floats.  stop is exclusive."""
    vals = []
    v = start
    while v < stop - 1e-9:
        vals.append(round(v, 6))
        v += step
    return vals


def format_val(v):
    """Format a float for use in filenames: 1.85 → '1.85', 35.0 → '35.0'."""
    return f"{v:.2f}"


def quantity_to_text(value):
    """Convert a FreeCAD quantity to plain numeric text without unit suffix."""
    s = str(value)
    if s.endswith(" mm"):
        s = s[:-3]
    return s


def load_label_helpers():
    """Load build/apply label helpers from label_face.FCMacro."""
    if not os.path.isfile(LABEL_MACRO_PATH):
        raise RuntimeError(f"Label macro not found: {LABEL_MACRO_PATH}")

    namespace = {"__name__": "__label_face_headless__"}
    with open(LABEL_MACRO_PATH, "r", encoding="utf-8") as f:
        exec(compile(f.read(), LABEL_MACRO_PATH, "exec"), namespace)

    build_label_solid = namespace.get("build_label_solid")
    apply_label_to_shape = namespace.get("apply_label_to_shape")
    if not build_label_solid or not apply_label_to_shape:
        raise RuntimeError("Label macro does not expose required helper functions")
    return build_label_solid, apply_label_to_shape


def export_shape_stl(shape, stl_path):
    """Tessellate *shape* and write an STL file.  Returns facet count."""
    mesh = Mesh.Mesh()
    shape = shape.copy()
    verts, tris = shape.tessellate(LINEAR_DEFLECTION)
    for tri in tris:
        mesh.addFacet(verts[tri[0]], verts[tri[1]], verts[tri[2]])
    mesh.write(stl_path)
    return mesh.CountFacets


def sweep_and_export(doc, varset, body, label, ranges,
                     build_label_solid=None, apply_label_to_shape=None):
    """Run a parametric sweep over *ranges* and export *body* for each combo."""
    param_names = list(ranges.keys())
    param_values = [frange(*ranges[p]) for p in param_names]
    combos = list(itertools.product(*param_values))

    print(f"\n=== {label} body: {len(combos)} combinations "
          f"({' x '.join(param_names)}) ===\n")

    for combo in combos:
        tag_parts = []
        for pname, pval in zip(param_names, combo):
            setattr(varset, pname, pval)
            tag_parts.append(f"{pname}={format_val(pval)}")
        doc.recompute()

        tag = "_".join(tag_parts)
        stl_name = f"{label}_{tag}.stl"
        stl_path = os.path.join(OUTPUT_DIR, stl_name)

        if body.Shape.isValid():
            shape_to_export = body.Shape
            if (label == "stroik" and ENABLE_STROIK_LABEL and
                    build_label_solid and apply_label_to_shape):
                try:
                    target_face = body.Shape.getElement(STROIK_LABEL_FACE)
                    label_text = quantity_to_text(getattr(varset, STROIK_LABEL_VAR))
                    label_solids = build_label_solid(
                        label_text,
                        target_face,
                        STROIK_LABEL_TEXT_HEIGHT,
                        STROIK_LABEL_DEPTH,
                        STROIK_LABEL_EMBOSS,
                    )
                    shape_to_export = apply_label_to_shape(
                        body.Shape,
                        label_solids,
                        STROIK_LABEL_EMBOSS,
                    )
                except Exception as exc:
                    print(f"  WARN {stl_name} — labeling failed: {exc}")

            n = export_shape_stl(shape_to_export, stl_path)
            print(f"  {stl_name}  ({n} facets)")
        else:
            print(f"  SKIP {stl_name} — invalid shape after recompute")


# --- Main --------------------------------------------------------------------

def run():
    if not os.path.isfile(PROJECT_PATH):
        print(f"ERROR: Project file not found: {PROJECT_PATH}")
        sys.exit(1)

    os.makedirs(OUTPUT_DIR, exist_ok=True)

    print(f"Opening project: {PROJECT_PATH}")
    doc = FreeCAD.openDocument(PROJECT_PATH)

    varset = doc.getObject("VarSet")
    stroik_body = doc.getObject("Body")      # Label: stroik
    listek_body = doc.getObject("Body001")   # Label: listek

    if not varset:
        print("ERROR: VarSet not found in project"); return
    if not stroik_body:
        print("ERROR: Body 'stroik' not found"); return
    if not listek_body:
        print("ERROR: Body 'listek' not found"); return

    build_label_solid = None
    apply_label_to_shape = None
    if ENABLE_STROIK_LABEL:
        try:
            build_label_solid, apply_label_to_shape = load_label_helpers()
            print(
                f"Loaded label macro, will engrave '{STROIK_LABEL_VAR}' "
                f"on {STROIK_LABEL_FACE} for stroik exports"
            )
        except Exception as exc:
            print(f"WARN: Could not load label macro, continuing without labels: {exc}")

    # Remember original values so we can restore them
    all_param_names = set(STROIK_RANGES) | set(LISTEK_RANGES)
    orig_vals = {p: getattr(varset, p) for p in all_param_names}

    # --- Stroik sweep: leaf_len × leaf_gap ---
    sweep_and_export(
        doc,
        varset,
        stroik_body,
        "stroik",
        STROIK_RANGES,
        build_label_solid,
        apply_label_to_shape,
    )

    # --- Listek sweep: leaf_end_thickness × leaf_start_thickness × leaf_len ---
    sweep_and_export(doc, varset, listek_body, "listek", LISTEK_RANGES)

    # --- Restore original values ---
    for pname, oval in orig_vals.items():
        setattr(varset, pname, oval)
    doc.recompute()

    FreeCAD.closeDocument(doc.Name)
    print(f"\nDone. STL files written to: {OUTPUT_DIR}")


run()
