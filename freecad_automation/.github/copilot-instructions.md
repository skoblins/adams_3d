# Overview 

FreeCAD automation and 3D printing helper scripts (Python, macros, bash).

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

- `generation/` — STL export scripts (see `generation-scripts` skill)
- `label/` — engraving/embossing macros (see `label-macro` skill)
- `.github/copilot-instructions.md` — this file
- `.github/skills/` — detailed skill docs

# Reference for Freecad API
https://wiki.freecad.org/FreeCAD_API