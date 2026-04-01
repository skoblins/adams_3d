#!/usr/bin/env python3
"""Export the Ring body (Body003) as a single STL, oriented on its bottom face.

The ring is parameter-independent — no sweep is performed.

Usage:
    freecad.cmd -c "exec(open('.../ring.py').read())"
  or:
    ./generate.sh ring
"""

import math
import os
import sys

try:
    _SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))
except NameError:
    _SCRIPT_DIR = "/home/adam/adams_3d/freecad_automation/generation"
if _SCRIPT_DIR not in sys.path:
    sys.path.insert(0, _SCRIPT_DIR)

import FreeCAD

from config import (
    PROJECT_PATH, OUTPUT_DIR,
    RING_BODY, RING_BOTTOM_FACE_FEATURE, RING_BOTTOM_FACE,
    RING_STL_NAME,
)
from helpers import export_shape_stl


def orient_shape_on_face(shape, face):
    """Rotate *shape* so that *face* lies flat on the XY plane at Z=0."""
    center = face.CenterOfMass
    try:
        uv = face.Surface.parameter(center)
        normal = face.normalAt(uv[0], uv[1]).normalize()
    except Exception:
        normal = face.normalAt(0, 0).normalize()

    desired = FreeCAD.Vector(0, 0, -1)
    oriented = shape.copy()
    shape_center = shape.BoundBox.Center

    if not normal.isEqual(desired, 1e-6):
        if normal.isEqual(-desired, 1e-6):
            oriented.rotate(shape_center, FreeCAD.Vector(1, 0, 0), 180)
        else:
            axis = normal.cross(desired)
            dot = max(-1.0, min(1.0, normal.dot(desired)))
            angle = math.degrees(math.acos(dot))
            oriented.rotate(shape_center, axis, angle)

    bb = oriented.BoundBox
    oriented.translate(FreeCAD.Vector(-bb.XMin, -bb.YMin, -bb.ZMin))
    return oriented


def run():
    if not os.path.isfile(PROJECT_PATH):
        print(f"ERROR: Project file not found: {PROJECT_PATH}")
        sys.exit(1)

    os.makedirs(OUTPUT_DIR, exist_ok=True)

    print(f"Opening project: {PROJECT_PATH}")
    doc = FreeCAD.openDocument(PROJECT_PATH)

    ring_body = doc.getObject(RING_BODY)
    if not ring_body:
        print(f"ERROR: Body '{RING_BODY}' (Ring) not found")
        FreeCAD.closeDocument(doc.Name)
        sys.exit(1)

    if not ring_body.Shape.isValid():
        print("ERROR: Ring body shape is invalid")
        FreeCAD.closeDocument(doc.Name)
        sys.exit(1)

    # Get the bottom face for orientation
    face_feature = doc.getObject(RING_BOTTOM_FACE_FEATURE)
    bottom_face = None
    if face_feature:
        try:
            bottom_face = face_feature.Shape.getElement(RING_BOTTOM_FACE)
        except Exception:
            pass
    if bottom_face is None:
        try:
            bottom_face = ring_body.Shape.getElement(RING_BOTTOM_FACE)
        except Exception:
            pass

    if bottom_face is not None:
        shape = orient_shape_on_face(ring_body.Shape, bottom_face)
        print(f"Oriented ring on {RING_BOTTOM_FACE_FEATURE}.{RING_BOTTOM_FACE}")
    else:
        print(f"WARN: Could not find {RING_BOTTOM_FACE_FEATURE}.{RING_BOTTOM_FACE}, "
              f"exporting without orientation")
        shape = ring_body.Shape

    stl_path = os.path.join(OUTPUT_DIR, RING_STL_NAME)
    n = export_shape_stl(shape, stl_path)
    print(f"  {RING_STL_NAME}  ({n} facets)")

    FreeCAD.closeDocument(doc.Name)
    print(f"\nDone. STL written to: {stl_path}")


run()
