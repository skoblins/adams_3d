# freecad_automation — quick ref

Parametric STL export from `stroik/stroik1-D-leaf_PLA_flexi-sealing.FCStd`.

FreeCAD project has two bodies:
- **Body** (stroik/reed) — swept over `leaf_len × leaf_gap`
- **Body001** (listek/leaf) — swept over `leaf_end_thickness × leaf_start_thickness × leaf_len`

## Usage

```bash
cd freecad_automation/generation
./generate.sh <target> [target ...]
```

### Targets

| Target | What it does | Script |
|---|---|---|
| `reeds` | Export individual stroik STLs (one per param combo), with engraved `leaf_gap` label | `reed.py` |
| `leafs` | Export individual listek STLs (one per param combo) | `leaf.py` |
| `leaf_matrix` | All listeks in a print-ready grid + separate label modifier STL | `leaf_matrix.py` |
| `box` | Listek pocket box (3-phase parallel pipeline) | `box_prepare.py` → `_row_worker.py` → `box_assemble.py` |
| `lid` | Listek pocket lid + text modifier STL | `lid.py` |
| `reed_box` | Stroik pocket box (same pipeline, `BOX_MODE=stroik`) | same as `box` |
| `reed_lid` | Stroik pocket lid + text modifier STL | `lid.py` (`BOX_MODE=stroik`) |

Multiple targets run in parallel:
```bash
./generate.sh reeds leafs box lid          # all listek + stroik
./generate.sh leaf_matrix                  # just the leaf grid
./generate.sh reed_box reed_lid            # just stroik boxes
```

## Key files

```
generation/
  config.py          # all tunables: paths, ranges, bed size, label params
  helpers.py         # shared utils: frange, export_shape_stl, layout, etc.
  generate.sh        # entry point — dispatches targets
  reed.py            # stroik body export
  leaf.py            # listek body export (individual STLs)
  leaf_matrix.py     # listek grid + label modifiers
  lid.py             # lid for listek or stroik pocket box
  box_prepare.py     # box phase 1: collect pockets, write manifest
  _row_worker.py     # box phase 2: build one row (parallel)
  box_assemble.py    # box phase 3: concatenate row STLs
  output/            # all generated STLs go here

label/
  label_face.FCMacro # text label engine (also FreeCAD GUI macro)
```

## Config cheat sheet

Edit `config.py` to change sweep ranges:

```python
# Stroik: (start, stop_exclusive, step)
STROIK_RANGES = {
    "leaf_len":  (34.0, 37, 1),
    "leaf_gap":  (1.5, 2.5, 0.2),
}

# Listek:
LISTEK_RANGES = {
    "leaf_end_thickness":   (0.2, 0.26, 0.02),
    "leaf_start_thickness": (1.40, 1.46, 0.02),
    "leaf_len":             (34.0, 37, 1),
}
```

Uncomment the "Easy ones" block at the bottom for quick dev testing (fewer combos).

Other useful knobs:
- `LEAF_MATRIX_SPACING` — gap between parts in grid (mm)
- `LEAF_MATRIX_LABEL_DEPTH` — label modifier thickness
- `LISTEK_POCKET_DEPTH`, `LISTEK_BOX_OUTER_MARGIN` — box dimensions
- `LISTEK_MAGNET_DIAMETER/DEPTH` — magnet pocket size
- `PRUSA_BED_X/Y`, `PRUSA_BED_MARGIN` — print area limits

## leaf_matrix output

Two STLs, load both into slicer:
1. `leaf_matrix.stl` — the leaf bodies (main material)
2. `leaf_matrix_labels.stl` — text labels as modifier (different color/material)

Labels sit at Z=0 flush with each leaf bottom, rotated 90° to use the long axis.

## FreeCAD runtime

Currently installed via **snap**:
```bash
freecad.cmd -c "exec(open('script.py').read())"  # headless
freecad                                            # GUI
```

## VarSet defaults (from FCStd)

| Variable | Default | Type |
|---|---|---|
| `d_inner` | 5.30 mm | Length |
| `d_outer` | 6.00 mm | Length |
| `d_outer_plug` | 6.05 mm | Distance |
| `leaf_end_thickness` | 0.19 mm | Distance |
| `leaf_gap` | 1.85 mm | Distance |
| `leaf_len` | 35.50 mm | Length |
| `leaf_start_thickness` | 1.42 mm | Distance |
| `plug_inner_start` | 4.00 mm | Distance |
| `plug_len` | 15.00 mm | Distance |
| `plug_outer_start` | 4.40 mm | Distance |
