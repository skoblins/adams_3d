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
- `label/` — FreeCAD macros for engraving/embossing text labels on part faces
- `.github/copilot-instructions.md` — this file

# Generation scripts

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

# Label macro

## label/label_face.FCMacro

Engraves or embosses VarSet variable values as text on a selected face of a body. Used to identify parts after 3D printing when doing parametric sweeps.

**Modes:**
- **GUI mode** — Run as a FreeCAD macro. Opens a dialog to pick variables, target body/face, text height, depth, and engrave/emboss. Adds a `VarLabel_Text` feature to the document with custom properties for later automation.
- **Headless API** — Import `build_label_solid()` and `apply_label_to_shape()` functions from the macro for use in generation scripts.

**Key functions:**
- `build_label_solid(text, face, text_height, depth, emboss, font_dir, font_file)` → returns `list[Part.Shape]` of per-glyph solids positioned on the face
- `apply_label_to_shape(body_shape, label_solids, emboss)` → returns modified `Part.Shape` with text cut/fused
- `find_font()` → searches Flatpak, system, and matplotlib font paths for `.ttf` files

**Custom properties stored on VarLabel_Text feature:**
- `VarLabel_Variables` — semicolon-separated list of VarSet variable names
- `VarLabel_Format` — Python format string for the label text
- `VarLabel_Target` — target body label
- `VarLabel_Face` — face name (e.g., `Face11`)
- `VarLabel_TextHeight`, `VarLabel_Depth`, `VarLabel_Emboss` — engraving parameters

**Limitations:**
- Works reliably on planar faces only. Curved faces may produce incorrect results.
- Text is generated via `Part.makeWireString()` (works in headless mode, unlike `Part::ShapeString`).
- Font directory path must include a trailing `/` for `Part.makeWireString()`.

# Conventions

- FreeCAD projects use `VarSet` objects to hold parametric variables. When creating parametric sweep scripts, read variables from the VarSet, modify them with `setattr(varset, name, value)`, call `doc.recompute()`, then export.
- Always restore original VarSet values after a sweep completes.
- STL filenames encode the parameter values: `{body_label}_{param1}={val1}_{param2}={val2}.stl`
- Mesh tolerance is controlled by `LINEAR_DEFLECTION` (default 0.1 mm).

# Reference for Freecad API
https://wiki.freecad.org/FreeCAD_API