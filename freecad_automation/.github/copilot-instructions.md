# Overview 

It's a project that contains programs helping in Freecad automation and 3d printing development. It includes python scripts, Freecad macros, and bash scripts for various tasks related to Freecad and 3d printing. The project is organized into different directories based on the type of activity, e.g. "generation" for scripts that generate stls from the Freecad projects. The list will be updated as new scripts are added.

# FreeCAD installation

FreeCAD is installed via Flatpak (`org.freecad.FreeCAD`). To run the CLI:

```bash
flatpak run --command=freecadcmd org.freecad.FreeCAD
```

Python scripts cannot be passed as positional arguments directly. Instead, use:

```bash
flatpak run --command=freecadcmd org.freecad.FreeCAD -c "exec(open('/path/to/script.py').read())"
```

Because of this, `__file__` is not available when scripts run via `exec()`. Scripts should handle both cases using a `try/except NameError` block to resolve `_SCRIPT_DIR`.

# Project structure

- `generation/` — scripts that export STL files from FreeCAD `.FCStd` projects
  - Each generation script has a companion `.sh` bash wrapper for convenience
  - Output STLs go into `generation/output/`
- `.github/copilot-instructions.md` — this file

# Generation scripts

## generation/export_stroik1_d_leaf.py

Exports STL meshes from `stroik/stroik1-D-leaf_PLA_flexi-sealing.FCStd` with parametric sweeps over VarSet variables.

**Bodies exported:**
- `stroik` (Body) — swept over `leaf_len × leaf_gap`
- `listek` (Body001) — swept over `leaf_end_thickness × leaf_start_thickness × leaf_len`

**Configuration:** Edit the `STROIK_RANGES` and `LISTEK_RANGES` dicts at the top of the script. Each range is a `(start, stop, step)` tuple where stop is exclusive (like Python `range()` but supports floats).

**Run:** `./freecad_automation/generation/export_stroik1_d_leaf.sh`

# Conventions

- FreeCAD projects use `VarSet` objects to hold parametric variables. When creating parametric sweep scripts, read variables from the VarSet, modify them with `setattr(varset, name, value)`, call `doc.recompute()`, then export.
- Always restore original VarSet values after a sweep completes.
- STL filenames encode the parameter values: `{body_label}_{param1}={val1}_{param2}={val2}.stl`
- Mesh tolerance is controlled by `LINEAR_DEFLECTION` (default 0.1 mm).

# Reference for Freecad API
https://wiki.freecad.org/FreeCAD_API