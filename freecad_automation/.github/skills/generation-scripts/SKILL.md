---
name: generation-scripts
description: "Use when writing or modifying FreeCAD generation/export scripts that produce STL files from .FCStd projects with parametric sweeps over VarSet variables. Covers export_stroik1_d_leaf.py and conventions for new generation scripts."
---

# Generation Scripts

## generation/export_stroik1_d_leaf.py

Exports STL meshes from `stroik/stroik1-D-leaf_PLA_flexi-sealing.FCStd` with parametric sweeps over VarSet variables.

**Bodies exported:**
- `stroik` (Body) — swept over `leaf_len × leaf_gap`
- `listek` (Body001) — swept over `leaf_end_thickness × leaf_start_thickness × leaf_len`
- `listek_pocket_box.stl` or `listek_pocket_box_1.stl` + `listek_pocket_box_2.stl` — rectangular tray(s) with pockets for exported `listek` variants

**Integrated labeling:**
- During `stroik` export, script can engrave value-only text of `leaf_gap` on `Face11` using helpers from `label/label_face.FCMacro`.

**Listek pocket tray details:**
- Pocket depth: `LISTEK_POCKET_DEPTH` (default `5.0 mm`)
- Pocket clearance: `LISTEK_POCKET_SIDE_GAP` (default `1.0 mm` on each side)
- Tray is rectangular (not forced square) and minimized to required size.
- Bed fit limit uses Prusa bed `250x210` with `10 mm` margin (`230x190 mm` usable).
- If one tray cannot fit all pockets, the script automatically splits into two trays.

**Configuration:** Edit the `STROIK_RANGES` and `LISTEK_RANGES` dicts at the top of the script. Each range is a `(start, stop, step)` tuple where stop is exclusive (like Python `range()` but supports floats).
Also edit `ENABLE_STROIK_LABEL`, `STROIK_LABEL_*`, and `LISTEK_*` constants for label/tray behavior.

**Run:** `./freecad_automation/generation/export_stroik1_d_leaf.sh`

## Conventions for generation scripts

- FreeCAD projects use `VarSet` objects to hold parametric variables. When creating parametric sweep scripts, read variables from the VarSet, modify them with `setattr(varset, name, value)`, call `doc.recompute()`, then export.
- Always restore original VarSet values after a sweep completes.
- STL filenames encode the parameter values: `{body_label}_{param1}={val1}_{param2}={val2}.stl`
- Mesh tolerance is controlled by `LINEAR_DEFLECTION` (default 0.1 mm).
- Each generation script has a companion `.sh` bash wrapper for convenience.
- Output STLs go into `generation/output/`.
