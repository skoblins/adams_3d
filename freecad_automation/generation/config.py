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

# --- Listek pocket box --------------------------------------------------------
LISTEK_POCKET_DEPTH = 10.0         # mm
LISTEK_POCKET_SIDE_GAP = 1.0      # mm on each side
LISTEK_BOX_BOTTOM_THICKNESS = 2.0 # mm
LISTEK_BOX_OUTER_MARGIN = 3.0     # mm
LISTEK_BOX_CELL_SPACING = 1.0     # mm between pockets
LISTEK_BOX_STL_NAME = "listek_pocket_box.stl"
LISTEK_BOX_SPLIT_NAME_FMT = "listek_pocket_box_{index}.stl"
LISTEK_BOX_MAX_COUNT = 2
LISTEK_BOX_LABEL_TEXT_HEIGHT = 3   # mm
LISTEK_BOX_LABEL_DEPTH = 0.8      # mm
LISTEK_BOX_LABEL_PARAMS = ["leaf_len", "leaf_start_thickness", "leaf_end_thickness"]

# --- Lid & magnets ------------------------------------------------------------
LISTEK_LID_THICKNESS = 3.4           # mm
LISTEK_LID_LIP_HEIGHT = 1.5          # mm  (lip that sits inside box rim)
LISTEK_LID_LIP_INSET = 0.3           # mm  (clearance per side for a snug fit)
LISTEK_MAGNET_DIAMETER = 5.0          # mm
LISTEK_MAGNET_DEPTH = 3              # mm  (pocket depth in both lid and box)
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

# "stroik" body — sweep over leaf_len × leaf_gap
# STROIK_RANGES = {
#     "leaf_len":  (35.0, 37, 0.5),   # mm — 35.0, 35.5, 36.0
#     "leaf_gap":  (1.75, 2.0, 0.05),   # mm — 1.75, 1.80, 1.85, 1.90, 1.95
# }

# "listek" body — sweep over leaf_end_thickness × leaf_start_thickness × leaf_len
# LISTEK_RANGES = {
#     "leaf_end_thickness":   (0.2, 0.26, 0.02),  # mm
#     "leaf_start_thickness": (1.38, 1.46, 0.02),  # mm
#     "leaf_len":             (35.0, 37.0, 0.5),    # mm — 36.0, 36.5
# }

STROIK_RANGES = {
    "leaf_len":  (35.0, 36.5, 0.5),   # mm — 35.0, 35.5, 36.0
    "leaf_gap":  (1.75, 2.1, 0.1),    # mm — 1.75, 1.80, 1.85, 1.90, 1.95, 2.00
}

LISTEK_RANGES = {
    "leaf_end_thickness":   (0.2, 0.26, 0.02),   # mm
    "leaf_start_thickness": (1.40, 1.46, 0.02),   # mm
    "leaf_len":             (35.0, 36.5, 0.5),     # mm — 35.0, 35.5, 36.0
}

## Easy ones for development testing!
# STROIK_RANGES = {
#     "leaf_len":  (36.0, 37, 0.5),   # mm — 35.0, 35.5, 36.0
#     "leaf_gap":  (1.85, 2.1, 0.1),    # mm — 1.75, 1.80, 1.85, 1.90, 1.95, 2.00
# }

# LISTEK_RANGES = {
#     "leaf_end_thickness":   (0.22, 0.26, 0.02),   # mm
#     "leaf_start_thickness": (1.42, 1.46, 0.02),   # mm
#     "leaf_len":             (36.0, 37, 0.5),     # mm — 35.0, 35.5, 36.0
# }