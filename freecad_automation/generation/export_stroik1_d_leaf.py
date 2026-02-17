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
import math
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

# --- Generation toggles -------------------------------------------------------
GENERATE_STROIK = False
GENERATE_LISTEK = False
GENERATE_LISTEK_BOX = True
GENERATE_LISTEK_LID = False

# --- Stroik labeling ----------------------------------------------------------
ENABLE_STROIK_LABEL = True
STROIK_LABEL_VAR = "leaf_gap"
STROIK_LABEL_FACE = "Face11"  # from: stroik1_D_leaf_PLA_flexi_sealing.Body.Pocket008.Face11
STROIK_LABEL_TEXT_HEIGHT = 3.0
STROIK_LABEL_DEPTH = 0.3
STROIK_LABEL_EMBOSS = False

# --- Listek pocket box --------------------------------------------------------
LISTEK_POCKET_DEPTH = 10.0         # mm
LISTEK_POCKET_SIDE_GAP = 1.0      # mm on each side
LISTEK_BOX_BOTTOM_THICKNESS = 2.0 # mm
LISTEK_BOX_OUTER_MARGIN = 3.0     # mm
LISTEK_BOX_CELL_SPACING = 1.0     # mm between pockets
LISTEK_BOX_STL_NAME = "listek_pocket_box.stl"
LISTEK_BOX_SPLIT_NAME_FMT = "listek_pocket_box_{index}.stl"
LISTEK_BOX_MAX_COUNT = 2
LISTEK_BOX_LABEL_TEXT_HEIGHT = 3  # mm
LISTEK_BOX_LABEL_DEPTH = 0.8        # mm
LISTEK_BOX_LABEL_PARAMS = ["leaf_len", "leaf_start_thickness", "leaf_end_thickness"]

# --- Lid & magnets ------------------------------------------------------------
LISTEK_LID_THICKNESS = 3.4           # mm
LISTEK_LID_LIP_HEIGHT = 1.5          # mm  (lip that sits inside box rim)
LISTEK_LID_LIP_INSET = 0.3           # mm  (clearance per side for a snug fit)
LISTEK_MAGNET_DIAMETER = 5.0          # mm
LISTEK_MAGNET_DEPTH = 3             # mm  (pocket depth in both lid and box)
LISTEK_MAGNET_CORNER_INSET = 3.0      # mm  (center offset from each corner)
LISTEK_LID_STL_NAME = "listek_pocket_lid.stl"
LISTEK_LID_SPLIT_NAME_FMT = "listek_pocket_lid_{index}.stl"

PRUSA_BED_X = 250.0
PRUSA_BED_Y = 210.0
PRUSA_BED_MARGIN = 10.0
LISTEK_BOX_MAX_X = PRUSA_BED_X - 2.0 * PRUSA_BED_MARGIN
LISTEK_BOX_MAX_Y = PRUSA_BED_Y - 2.0 * PRUSA_BED_MARGIN

# --- Parameter sweep ranges ---------------------------------------------------
# Each range is (start, stop, step) — stop is EXCLUSIVE, like Python's range()
# but supports floats.  A single-value "range" looks like (val, val+step, step).
#
# "stroik" body — sweep over leaf_len × leaf_gap
# STROIK_RANGES = {
#     "leaf_len":  (35.0, 37, 0.5),   # mm — 35.0, 35.5, 36.0
#     "leaf_gap":  (1.75, 2.0, 0.05),   # mm — 1.75, 1.80, 1.85, 1.90, 1.95
# }

# # "listek" body — sweep over leaf_end_thickness × leaf_start_thickness × leaf_len
# LISTEK_RANGES = {
#     "leaf_end_thickness":   (0.2, 0.26, 0.02),  # mm
#     "leaf_start_thickness": (1.38, 1.46, 0.02),  # mm
#     "leaf_len":             (35.0, 37.0, 0.5),    # mm — 36.0, 36.5
# }

STROIK_RANGES = {
    "leaf_len":  (35.0, 36.5, 0.5),   # mm — 36.0, 36.5
    "leaf_gap":  (1.75, 2.1, 0.1),   # mm — 1.75, 1.80, 1.85, 1.90, 1.95
}

# "listek" body — sweep over leaf_end_thickness × leaf_start_thickness × leaf_len
LISTEK_RANGES = {
    "leaf_end_thickness":   (0.2, 0.26, 0.02),  # mm
    "leaf_start_thickness": (1.40, 1.46, 0.02),  # mm
    "leaf_len":             (35.0, 36.5, 0.5),    # mm — 36.0, 36.5
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


def flat_pocket_size_from_shape(shape, side_gap):
    """
    Return (sx, sy) pocket size for a flat-laying part.

    Uses the two largest bounding-box dimensions so pocket sizing does not
    depend on how the source body axes are oriented in the FCStd model.
    """
    bb = shape.BoundBox
    dims = sorted([bb.XLength, bb.YLength, bb.ZLength], reverse=True)
    sx = dims[0] + 2.0 * side_gap
    sy = dims[1] + 2.0 * side_gap
    return sx, sy


def _box_dims(cols, rows, cell_x, cell_y):
    width = (
        2.0 * LISTEK_BOX_OUTER_MARGIN
        + cols * cell_x
        + max(0, cols - 1) * LISTEK_BOX_CELL_SPACING
    )
    height = (
        2.0 * LISTEK_BOX_OUTER_MARGIN
        + rows * cell_y
        + max(0, rows - 1) * LISTEK_BOX_CELL_SPACING
    )
    return width, height


def compute_best_layout(pocket_sizes):
    """Find the smallest-area rectangular pocket layout that fits bed limits."""
    if not pocket_sizes:
        return None

    n = len(pocket_sizes)
    max_x = max(sx for sx, _ in pocket_sizes)
    max_y = max(sy for _, sy in pocket_sizes)

    best = None
    for swap in (False, True):
        cell_x, cell_y = (max_y, max_x) if swap else (max_x, max_y)
        for cols in range(1, n + 1):
            rows = int(math.ceil(float(n) / cols))
            width, height = _box_dims(cols, rows, cell_x, cell_y)
            if width <= LISTEK_BOX_MAX_X + 1e-9 and height <= LISTEK_BOX_MAX_Y + 1e-9:
                area = width * height
                score = (area, max(width, height), width + height)
                if best is None or score < best["score"]:
                    best = {
                        "cols": cols,
                        "rows": rows,
                        "cell_x": cell_x,
                        "cell_y": cell_y,
                        "width": width,
                        "height": height,
                        "swap": swap,
                        "score": score,
                    }
    return best


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
    pocket_z = box_height - LISTEK_POCKET_DEPTH

    pockets = []
    pocket_positions = []  # (px, py, sx, sy) for label engraving
    for i, (sx_raw, sy_raw) in enumerate(pocket_sizes):
        sx, sy = (sy_raw, sx_raw) if swap else (sx_raw, sy_raw)

        row = i // cols
        col = i % cols
        cell_min_x = x0 + col * step_x
        cell_min_y = y0 + row * step_y

        px = cell_min_x + (cell_x - sx) / 2.0
        py = cell_min_y + (cell_y - sy) / 2.0
        pocket = Part.makeBox(sx, sy, LISTEK_POCKET_DEPTH,
                              FreeCAD.Vector(px, py, pocket_z))
        pockets.append(pocket)
        pocket_positions.append((px, py, sx, sy))

    tray = tray.cut(Part.makeCompound(pockets))

    # Engrave parameter labels at each pocket bottom
    if build_label_solid and apply_label_to_shape and pocket_labels:
        for i, (px, py, sx, sy) in enumerate(pocket_positions):
            if i >= len(pocket_labels) or not pocket_labels[i]:
                continue
            try:
                # Synthetic face at pocket bottom, normal pointing up
                bottom_face = Part.makePlane(
                    sx, sy,
                    FreeCAD.Vector(px, py, pocket_z),
                    FreeCAD.Vector(0, 0, 1),
                )
                label_solids = build_label_solid(
                    pocket_labels[i],
                    bottom_face,
                    LISTEK_BOX_LABEL_TEXT_HEIGHT,
                    LISTEK_BOX_LABEL_DEPTH,
                    False,  # engrave
                )
                tray = apply_label_to_shape(tray, label_solids, False)
            except Exception as exc:
                print(f"  WARN pocket {i+1} label failed: {exc}")

    # Cut magnet pockets at corners of box (from the top)
    box_mag_z = box_height - LISTEK_MAGNET_DEPTH
    tray = _cut_magnet_pockets(tray, width, height, box_mag_z)

    return tray


def _cut_magnet_pockets(shape, width, height, z_bottom):
    """Cut cylindrical magnet pockets at the four corners of a rectangle."""
    r = LISTEK_MAGNET_DIAMETER / 2.0
    inset = LISTEK_MAGNET_CORNER_INSET
    corners = [
        (inset, inset),
        (width - inset, inset),
        (inset, height - inset),
        (width - inset, height - inset),
    ]
    for cx, cy in corners:
        cyl = Part.makeCylinder(
            r, LISTEK_MAGNET_DEPTH,
            FreeCAD.Vector(cx, cy, z_bottom),
            FreeCAD.Vector(0, 0, 1),
        )
        shape = shape.cut(cyl)
    return shape


def build_listek_lid(layout):
    """Build a lid that sits on top of the pocket box with matching magnet pockets."""
    width = layout["width"]
    height = layout["height"]

    lid_total_h = LISTEK_LID_THICKNESS + LISTEK_LID_LIP_HEIGHT

    # Outer slab
    lid = Part.makeBox(width, height, lid_total_h, FreeCAD.Vector(0, 0, 0))

    # Cut the lip recess: remove material around the lip so only the
    # inner block remains as a downward-protruding lip.
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
        lip_cut = outer_block.cut(inner_block)
        lid = lid.cut(lip_cut)

    # Magnet pockets above the lip (so they don't intersect the lip)
    lid = _cut_magnet_pockets(lid, width, height, LISTEK_LID_LIP_HEIGHT)

    # Cut clearance holes in the lip for the box's magnets (from z=0 upward)
    r = LISTEK_MAGNET_DIAMETER / 2.0
    inset = LISTEK_MAGNET_CORNER_INSET
    corners = [
        (inset, inset),
        (width - inset, inset),
        (inset, height - inset),
        (width - inset, height - inset),
    ]
    for cx, cy in corners:
        cyl = Part.makeCylinder(
            r, LISTEK_LID_LIP_HEIGHT,
            FreeCAD.Vector(cx, cy, 0),
            FreeCAD.Vector(0, 0, 1),
        )
        lid = lid.cut(cyl)

    return lid


def partition_listek_boxes(pocket_sizes, pocket_labels):
    """Return one or two box specs so all pockets fit within bed limits."""
    one_layout = compute_best_layout(pocket_sizes)
    if one_layout:
        return [(pocket_sizes, pocket_labels, one_layout)]

    if LISTEK_BOX_MAX_COUNT < 2:
        raise RuntimeError("Single listek box does not fit bed limits")

    n = len(pocket_sizes)
    best_split = None
    for split_at in range(1, n):
        first_s = pocket_sizes[:split_at]
        second_s = pocket_sizes[split_at:]
        l1 = compute_best_layout(first_s)
        l2 = compute_best_layout(second_s)
        if not l1 or not l2:
            continue

        total_area = l1["width"] * l1["height"] + l2["width"] * l2["height"]
        score = (
            total_area,
            max(l1["width"] * l1["height"], l2["width"] * l2["height"]),
            abs(len(first_s) - len(second_s)),
        )
        if best_split is None or score < best_split["score"]:
            best_split = {
                "score": score,
                "split_at": split_at,
                "specs": [
                    (first_s, pocket_labels[:split_at], l1),
                    (second_s, pocket_labels[split_at:], l2),
                ],
            }

    if not best_split:
        raise RuntimeError(
            "Could not fit listek pockets into one or two boxes within "
            f"{LISTEK_BOX_MAX_X:.1f}x{LISTEK_BOX_MAX_Y:.1f} mm"
        )

    return best_split["specs"]


def sweep_and_export(doc, varset, body, label, ranges,
                     build_label_solid=None, apply_label_to_shape=None,
                     export_stls=True):
    """Run a parametric sweep over *ranges* and export *body* for each combo."""
    param_names = list(ranges.keys())
    param_values = [frange(*ranges[p]) for p in param_names]
    combos = list(itertools.product(*param_values))

    print(f"\n=== {label} body: {len(combos)} combinations "
          f"({' x '.join(param_names)}) ===\n")

    pocket_sizes = []
    pocket_labels = []

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

            if export_stls:
                n = export_shape_stl(shape_to_export, stl_path)
                print(f"  {stl_name}  ({n} facets)")

            if label == "listek" and (GENERATE_LISTEK_BOX or GENERATE_LISTEK_LID):
                sx, sy = flat_pocket_size_from_shape(
                    shape_to_export,
                    LISTEK_POCKET_SIDE_GAP,
                )
                pocket_sizes.append((sx, sy))
                lbl = "/".join(format_val(combo[param_names.index(p)])
                              for p in LISTEK_BOX_LABEL_PARAMS
                              if p in param_names)
                pocket_labels.append(lbl)
        else:
            print(f"  SKIP {stl_name} — invalid shape after recompute")

    return pocket_sizes, pocket_labels


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
    if GENERATE_STROIK:
        sweep_and_export(
            doc,
            varset,
            stroik_body,
            "stroik",
            STROIK_RANGES,
            build_label_solid,
            apply_label_to_shape,
        )
    else:
        print("\n--- Skipping stroik sweep (GENERATE_STROIK=False) ---")

    # --- Listek sweep: leaf_end_thickness × leaf_start_thickness × leaf_len ---
    # The sweep must run whenever any listek output (STLs, box, or lid) is needed,
    # because box/lid dimensions are derived from the swept pocket sizes.
    need_listek_sweep = GENERATE_LISTEK or GENERATE_LISTEK_BOX or GENERATE_LISTEK_LID
    listek_pocket_sizes = []
    listek_pocket_labels = []
    if need_listek_sweep:
        listek_pocket_sizes, listek_pocket_labels = sweep_and_export(
            doc,
            varset,
            listek_body,
            "listek",
            LISTEK_RANGES,
            export_stls=GENERATE_LISTEK,
        )
    else:
        print("\n--- Skipping listek sweep (nothing enabled) ---")

    if (GENERATE_LISTEK_BOX or GENERATE_LISTEK_LID) and listek_pocket_sizes:
        print(
            "\n=== Building listek pocket box/lid with bed limit "
            f"{LISTEK_BOX_MAX_X:.1f}x{LISTEK_BOX_MAX_Y:.1f} mm ===\n"
        )
        box_specs = partition_listek_boxes(listek_pocket_sizes, listek_pocket_labels)

        for i, (box_pockets, box_labels, layout) in enumerate(box_specs, start=1):
            # Build and export pocket box
            if GENERATE_LISTEK_BOX:
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
                print(
                    f"  {stl_name}  ({n} facets) "
                    f"size={layout['width']:.1f}x{layout['height']:.1f} mm "
                    f"pockets={len(box_pockets)}"
                )

            # Build and export matching lid
            if GENERATE_LISTEK_LID:
                lid_shape = build_listek_lid(layout)
                if len(box_specs) == 1:
                    lid_name = LISTEK_LID_STL_NAME
                else:
                    lid_name = LISTEK_LID_SPLIT_NAME_FMT.format(index=i)
                lid_path = os.path.join(OUTPUT_DIR, lid_name)
                n_lid = export_shape_stl(lid_shape, lid_path)
                print(
                    f"  {lid_name}  ({n_lid} facets) "
                    f"size={layout['width']:.1f}x{layout['height']:.1f} mm"
                )

    # --- Restore original values ---
    for pname, oval in orig_vals.items():
        setattr(varset, pname, oval)
    doc.recompute()

    FreeCAD.closeDocument(doc.Name)
    print(f"\nDone. STL files written to: {OUTPUT_DIR}")


run()
