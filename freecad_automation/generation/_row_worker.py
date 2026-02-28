#!/usr/bin/env python3
"""Row-strip worker for parallel box building.

Invoked as a subprocess via generate.sh:
    ROW_WORKER_ARGS=<pkl> ROW_WORKER_OUTPUT=<stl> \
        freecadcmd -c "exec(open('_row_worker.py').read())"

Reads row build arguments from a pickle file, builds one horizontal strip
of the pocket tray (boolean cuts + labels), and exports the result directly
as an STL file.
"""

import os
import pickle
import sys

# When run via exec(), sys.argv parsing differs — grab args from env.
_ARGS_FILE = os.environ.get("ROW_WORKER_ARGS")
_OUTPUT_FILE = os.environ.get("ROW_WORKER_OUTPUT")

if not _ARGS_FILE or not _OUTPUT_FILE:
    print("ERROR: ROW_WORKER_ARGS / ROW_WORKER_OUTPUT env vars not set")
    sys.exit(1)

import FreeCAD
import Mesh
import Part

with open(_ARGS_FILE, "rb") as f:
    args = pickle.load(f)

(width, y_start, y_end, box_height,
 pocket_z, pocket_depth,
 lip_cut_data,
 row_pockets,
 magnet_entries) = args

# Build the strip solid
strip = Part.makeBox(width, y_end - y_start, box_height,
                     FreeCAD.Vector(0, y_start, 0))

cut_solids = []

# Lip recess portion clipped to this strip's Y range
if lip_cut_data:
    lx, ly_gs, ly_ge, lz, lw, lh = lip_cut_data
    cy0 = max(ly_gs, y_start)
    cy1 = min(ly_ge, y_end)
    if cy1 > cy0 + 1e-9:
        cut_solids.append(Part.makeBox(
            lw, cy1 - cy0, lh,
            FreeCAD.Vector(lx, cy0, lz),
        ))

# Pockets
for px, py, sx, sy in row_pockets:
    cut_solids.append(Part.makeBox(
        sx, sy, pocket_depth,
        FreeCAD.Vector(px, py, pocket_z),
    ))

# Magnet pockets
for cx, cy, r, md, mz in magnet_entries:
    cut_solids.append(Part.makeCylinder(
        r, md, FreeCAD.Vector(cx, cy, mz), FreeCAD.Vector(0, 0, 1),
    ))

if cut_solids:
    strip = strip.cut(Part.makeCompound(cut_solids))

# Tessellate and write STL
mesh = Mesh.Mesh()
strip_copy = strip.copy()
verts, tris = strip_copy.tessellate(0.1)   # LINEAR_DEFLECTION
for tri in tris:
    mesh.addFacet(verts[tri[0]], verts[tri[1]], verts[tri[2]])
mesh.write(_OUTPUT_FILE)

print(f"  Row strip y=[{y_start:.1f}, {y_end:.1f}] done "
      f"({len(row_pockets)} pockets, {mesh.CountFacets} facets)")
