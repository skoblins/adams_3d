---
name: label-macro
description: "Use when engraving or embossing text labels on FreeCAD part faces, using label/label_face.FCMacro in GUI or headless mode. Covers build_label_solid, apply_label_to_shape, and VarLabel custom properties."
---

# Label Macro

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
