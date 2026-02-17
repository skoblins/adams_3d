"""Shared utility functions for stroik/listek export scripts."""

import itertools
import math
import os
import sys

import FreeCAD
import Mesh
import Part

from config import (
    PROJECT_PATH, LABEL_MACRO_PATH, OUTPUT_DIR, LINEAR_DEFLECTION,
    LISTEK_POCKET_SIDE_GAP, LISTEK_BOX_LABEL_PARAMS,
    LISTEK_BOX_OUTER_MARGIN, LISTEK_BOX_CELL_SPACING,
    LISTEK_BOX_MAX_X, LISTEK_BOX_MAX_Y, LISTEK_BOX_MAX_COUNT,
    LISTEK_MAGNET_DIAMETER, LISTEK_MAGNET_DEPTH, LISTEK_MAGNET_CORNER_INSET,
    LISTEK_RANGES,
)


# --- Pure helpers -------------------------------------------------------------

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


# --- FreeCAD helpers ----------------------------------------------------------

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


# --- Project I/O --------------------------------------------------------------

def open_project():
    """Open the FreeCAD project, return (doc, varset, stroik_body, listek_body)."""
    if not os.path.isfile(PROJECT_PATH):
        print(f"ERROR: Project file not found: {PROJECT_PATH}")
        sys.exit(1)

    os.makedirs(OUTPUT_DIR, exist_ok=True)

    print(f"Opening project: {PROJECT_PATH}")
    doc = FreeCAD.openDocument(PROJECT_PATH)

    varset = doc.getObject("VarSet")
    stroik_body = doc.getObject("Body")       # Label: stroik
    listek_body = doc.getObject("Body001")    # Label: listek

    if not varset:
        raise RuntimeError("VarSet not found in project")
    if not stroik_body:
        raise RuntimeError("Body 'stroik' not found")
    if not listek_body:
        raise RuntimeError("Body 'listek' not found")

    return doc, varset, stroik_body, listek_body


def close_project(doc, varset, orig_vals):
    """Restore original parameter values and close the document."""
    for pname, oval in orig_vals.items():
        setattr(varset, pname, oval)
    doc.recompute()
    FreeCAD.closeDocument(doc.Name)


# --- Layout / pocket helpers --------------------------------------------------

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


def make_magnet_solids(width, height, z_bottom):
    """Return a list of cylindrical magnet pocket solids at the four corners."""
    r = LISTEK_MAGNET_DIAMETER / 2.0
    inset = LISTEK_MAGNET_CORNER_INSET
    corners = [
        (inset, inset),
        (width - inset, inset),
        (inset, height - inset),
        (width - inset, height - inset),
    ]
    return [
        Part.makeCylinder(
            r, LISTEK_MAGNET_DEPTH,
            FreeCAD.Vector(cx, cy, z_bottom),
            FreeCAD.Vector(0, 0, 1),
        )
        for cx, cy in corners
    ]


def cut_magnet_pockets(shape, width, height, z_bottom):
    """Cut cylindrical magnet pockets at the four corners of a rectangle."""
    solids = make_magnet_solids(width, height, z_bottom)
    return shape.cut(Part.makeCompound(solids))


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


def collect_listek_pockets(doc, varset, listek_body):
    """Sweep listek parameter ranges and collect pocket sizes + labels (no STL export)."""
    param_names = list(LISTEK_RANGES.keys())
    param_values = [frange(*LISTEK_RANGES[p]) for p in param_names]
    combos = list(itertools.product(*param_values))

    print(f"\n=== Collecting listek pocket sizes: {len(combos)} combinations "
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

        if listek_body.Shape.isValid():
            sx, sy = flat_pocket_size_from_shape(
                listek_body.Shape, LISTEK_POCKET_SIDE_GAP)
            pocket_sizes.append((sx, sy))
            lbl = "/".join(format_val(combo[param_names.index(p)])
                          for p in LISTEK_BOX_LABEL_PARAMS
                          if p in param_names)
            pocket_labels.append(lbl)
            print(f"  {tag} -> pocket {sx:.1f}x{sy:.1f} mm")
        else:
            print(f"  SKIP {tag} — invalid shape")

    return pocket_sizes, pocket_labels
