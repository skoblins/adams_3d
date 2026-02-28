#!/usr/bin/env python3
"""Concatenate row-strip STL files into final pocket box STL(s).

Reads the manifest JSON produced by box_prepare.py, concatenates each row's
binary STL into one combined file per box.  No FreeCAD required — this is
pure-Python binary STL I/O.

Usage (called by generate.sh, not directly):
    ROW_MANIFEST=/path/manifest.json python3 box_assemble.py
"""

import json
import os
import shutil
import struct
import sys


def read_binary_stl_triangles(path):
    """Read a binary STL file and return list of 50-byte triangle records."""
    with open(path, "rb") as f:
        header = f.read(80)
        count_data = f.read(4)
        if len(count_data) < 4:
            return []
        n_triangles = struct.unpack("<I", count_data)[0]
        triangles = []
        for _ in range(n_triangles):
            tri = f.read(50)  # 12 floats (normal + 3 verts) + 2 byte attr
            if len(tri) < 50:
                break
            triangles.append(tri)
        return triangles


def write_binary_stl(path, all_triangles, name="combined"):
    """Write a binary STL file from a flat list of 50-byte triangle records."""
    header = name.encode("ascii")[:80].ljust(80, b"\0")
    with open(path, "wb") as f:
        f.write(header)
        f.write(struct.pack("<I", len(all_triangles)))
        for tri in all_triangles:
            f.write(tri)


MANIFEST_PATH = os.environ.get("ROW_MANIFEST")
if not MANIFEST_PATH:
    print("ERROR: ROW_MANIFEST env var not set")
    sys.exit(1)

with open(MANIFEST_PATH, "r") as f:
    manifest = json.load(f)

output_dir = manifest["output_dir"]
tmp_dir = manifest["tmp_dir"]

for box in manifest["boxes"]:
    stl_name = box["stl_name"]
    all_tris = []
    for row in box["rows"]:
        stl_path = row["stl_file"]
        if not os.path.isfile(stl_path):
            print(f"ERROR: missing STL file: {stl_path}")
            sys.exit(1)
        tris = read_binary_stl_triangles(stl_path)
        all_tris.extend(tris)

    out_path = os.path.join(output_dir, stl_name)
    os.makedirs(output_dir, exist_ok=True)
    write_binary_stl(out_path, all_tris, name=stl_name)
    print(f"  {stl_name}  ({len(all_tris)} facets)  "
          f"size={box['width']:.1f}x{box['height']:.1f} mm  "
          f"pockets={box['pocket_count']}")

# Clean up temp directory
shutil.rmtree(tmp_dir, ignore_errors=True)

print(f"\nDone. STL files written to: {output_dir}")
