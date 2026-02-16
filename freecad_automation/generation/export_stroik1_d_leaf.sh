#!/usr/bin/env bash
# Export all bodies from stroik1-D-leaf_PLA_flexi-sealing.FCStd as STL files.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
flatpak run --command=freecadcmd org.freecad.FreeCAD -c \
  "exec(open('${SCRIPT_DIR}/export_stroik1_d_leaf.py').read())"
