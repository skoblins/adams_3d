"""Shared configuration for stroik1-D-leaf_PLA_flexi-sealing export scripts.

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

import os

try:
    _SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
except NameError:
    _SCRIPT_DIR = "/home/adam/adams_3d/freecad_automation/generation"

# --- Paths --------------------------------------------------------------------

PROJECT_PATH = os.path.normpath(
    os.path.join(_SCRIPT_DIR, "..", "..", "stroik",
                 "stroik.FCStd")
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
STROIK_LABEL_FACE = "Face2"
STROIK_LABEL_TEXT_HEIGHT = 2
STROIK_LABEL_DEPTH = 0.4
STROIK_LABEL_EMBOSS = False

# --- Listek pocket box --------------------------------------------------------
LISTEK_POCKET_DEPTH = 10.0         # mm
LISTEK_POCKET_SIDE_GAP = 3.0      # mm on each side
LISTEK_BOX_BOTTOM_THICKNESS = 1.5 # mm
LISTEK_BOX_OUTER_MARGIN = 2.0     # mm
LISTEK_BOX_CELL_SPACING = 1.0     # mm between pockets
LISTEK_BOX_STL_NAME = "listek_pocket_box.stl"
LISTEK_BOX_SPLIT_NAME_FMT = "listek_pocket_box_{index}.stl"
LISTEK_BOX_MAX_COUNT = 2
LISTEK_BOX_LABEL_TEXT_HEIGHT = 3   # mm
LISTEK_BOX_LABEL_DEPTH = 0.25      # mm
LISTEK_BOX_LABEL_PARAMS = ["leaf_len", "leaf_start_thickness", "leaf_end_thickness"]

# --- Lid & magnets ------------------------------------------------------------
LISTEK_LID_THICKNESS = 1.5           # mm
LISTEK_LID_LIP_HEIGHT = 1.5          # mm  (lip that sits inside box rim)
LISTEK_LID_LIP_INSET = 0.3           # mm  (clearance per side for a snug fit)
LISTEK_MAGNET_DIAMETER = 3.1          # mm
LISTEK_MAGNET_DEPTH = 1.1              # mm  (pocket depth in both lid and box)
LISTEK_MAGNET_CORNER_INSET = 3.0      # mm  (center offset from each corner)
LISTEK_LID_LABEL_DEPTH = 0.25              # mm  (text depth on lid bottom)
LISTEK_LID_STL_NAME = "listek_pocket_lid.stl"
LISTEK_LID_SPLIT_NAME_FMT = "listek_pocket_lid_{index}.stl"
LISTEK_LID_TEXT_STL_NAME = "listek_pocket_lid_text.stl"
LISTEK_LID_TEXT_SPLIT_NAME_FMT = "listek_pocket_lid_text_{index}.stl"

# --- Stroik (reed) pocket box -------------------------------------------------
# Pocket depth = d_outer (radius!) * 2 * STROIK_POCKET_DEPTH_FACTOR
# d_outer default = 6.0 mm → diameter = 12.0 mm → pocket = 14.4 mm
STROIK_POCKET_DEPTH_FACTOR = 1.2
STROIK_BOX_STL_NAME = "stroik_pocket_box.stl"
STROIK_BOX_SPLIT_NAME_FMT = "stroik_pocket_box_{index}.stl"
STROIK_BOX_LABEL_TEXT_HEIGHT = 5   # mm
STROIK_BOX_LABEL_PARAMS = ["leaf_len", "leaf_gap"]

STROIK_LID_STL_NAME = "stroik_pocket_lid.stl"
STROIK_LID_SPLIT_NAME_FMT = "stroik_pocket_lid_{index}.stl"
STROIK_LID_TEXT_STL_NAME = "stroik_pocket_lid_text.stl"
STROIK_LID_TEXT_SPLIT_NAME_FMT = "stroik_pocket_lid_text_{index}.stl"

PRUSA_BED_X = 250.0
PRUSA_BED_Y = 210.0
PRUSA_BED_MARGIN = 10.0
LISTEK_BOX_MAX_X = PRUSA_BED_X - 2.0 * PRUSA_BED_MARGIN
LISTEK_BOX_MAX_Y = PRUSA_BED_Y - 2.0 * PRUSA_BED_MARGIN

# --- Leaf matrix layout (print-ready grid with modifier labels) ---------------
LEAF_MATRIX_BOTTOM_FACE_FEATURE = "Pocket006"  # feature inside Body002 (Leaf)
LEAF_MATRIX_BOTTOM_FACE = "Face2"                # face on that feature
LEAF_MATRIX_SPACING = 3.0           # mm gap between parts in the grid
LEAF_MATRIX_LABEL_DEPTH = 0.2       # mm label thickness (modifier into part)
LEAF_MATRIX_LABEL_MARGIN = 0.3      # mm text margin inside face boundary
LEAF_MATRIX_STL_NAME = "leaf_matrix.stl"
LEAF_MATRIX_LABEL_STL_NAME = "leaf_matrix_labels.stl"
LEAF_MATRIX_LABEL_PARAMS = ["leaf_len", "leaf_start_thickness", "leaf_end_thickness"]

# --- Reed matrix layout (print-ready grid with modifier labels) ---------------
REED_MATRIX_BOTTOM_FACE_FEATURE = "Mirrored"  # feature inside Body (MainPart)
REED_MATRIX_BOTTOM_FACE = "Face1"              # face on that feature
REED_MATRIX_SPACING = 3.0               # mm gap between parts in the grid
REED_MATRIX_LABEL_DEPTH = 0.4           # mm label thickness (modifier into part)
REED_MATRIX_LABEL_MARGIN = 1.0          # mm text margin inside face boundary
REED_MATRIX_RAFT_EXTEND = 0           # mm raft extends beyond reed footprint
REED_MATRIX_RAFT_THICKNESS = 0.4        # mm raft thickness at z=0
REED_MATRIX_STL_NAME = "reed_matrix.stl"
REED_MATRIX_LABEL_STL_NAME = "reed_matrix_labels.stl"
REED_MATRIX_LABEL_PARAMS = ["leaf_len", "leaf_gap"]

# --- Ring export (Body003) ----------------------------------------------------
RING_BODY = "Body003"                    # internal name in .FCStd
RING_BOTTOM_FACE_FEATURE = "Pad005"      # feature whose Face5 is the bottom
RING_BOTTOM_FACE = "Face5"               # face to place on the build plate
RING_STL_NAME = "ring.stl"

# --- Parameter sweep ranges ---------------------------------------------------
# Each range is (start, stop, step) — stop is EXCLUSIVE, like Python's range()
# but supports floats.  A single-value "range" looks like (val, val+step, step).

# pipe reed

STROIK_RANGES = {
    "leaf_len":  (28.0, 29, 1), # [mm]
    "leaf_gap":  (0.7, 0.9, 0.1), # [mm]
}

LISTEK_RANGES = {
    "leaf_end_thickness":   (0.2, 0.4, 0.1),   # mm
    "leaf_start_thickness": (1.2, 1.4, 0.1),   # mm
    "leaf_len":             STROIK_RANGES["leaf_len"],     # mm 
}

# # Burdon
# STROIK_RANGES = {
#     "leaf_len":  (36.0, 39, 1),   # mm — 35.0, 35.5, 36.0
#     "leaf_gap":  (2.6, 3.2, 0.2),    # mm — 1.75, 1.80, 1.85, 1.90, 1.95, 2.00
# }
# LISTEK_RANGES = {
#    "leaf_end_thickness":   (1, 1.1, 0.1),   # mm
#    "leaf_start_thickness": (0.5, 0.8, 0.1),   # mm
#    "leaf_len":             (36.0, 39, 1),     # mm — 35.0, 35.5, 36.0
# }

# next: leaf: 36/0.5/1, reed: 36/2.9 i 36/3.2

########################################################################
# # Easy ones for development testing!
########################################################################
# STROIK_RANGES = {
#     "leaf_len":  (36.0, 37, 0.5),   # mm — 35.0, 35.5, 36.0
#     "leaf_gap":  (1.85, 2.1, 0.1),    # mm — 1.75, 1.80, 1.85, 1.90, 1.95, 2.00
# }

# LISTEK_RANGES = {
#     "leaf_end_thickness":   (0.22, 0.26, 0.02),   # mm
#     "leaf_start_thickness": (1.42, 1.46, 0.02),   # mm
#     "leaf_len":             (36.0, 37, 0.5),     # mm — 35.0, 35.5, 36.0
# }
