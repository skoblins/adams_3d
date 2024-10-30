include <bearings/clip-monolith.scad>
include <connectors/lin_screw.scad>

module linear_bearings(selection = 0, h=10, dInner=25, dOuter=35, dInnerLoose=26) {

    if(selection == 0 || selection == 1) {
        linear_bearing_with_tightening_clip(h, dInner, dOuter, dInnerLoose)
            right(h/4) down(25/2) align(BOTTOM, align=LEFT)
                segment_compliment_with_bolts(spin=-90, orient=FRONT, length = 25, height = 10, width = 30, nut_height = 8, nut_width = 3, screw_d = 5, screw_head_h = 5, screw_head_d = 8.5)
                    left(dInner/2) fwd(dOuter/2) fillet(l=h, r=dOuter/2, spin=0, orient=BOTTOM)
                        back(dOuter) xrot(180) fillet(l=h, r=dOuter/2, spin=0, orient=TOP);
    }

    if(selection == 0 || selection == 2) {
        linear_bearing_with_tightening_clip(h, dInner, dOuter, dInnerLoose)
            right(4*h) down(30/2) back(2.5) align(BOTTOM, align=LEFT)
                zrot(180) segment_with_square_nuts(spin=-90, orient=FRONT, length = 25, height = 10, width = 30, nut_height = 8, nut_width = 3, screw_d = 5, screw_head_h = 5, screw_head_d = 8.5){
                    left(30/2) fwd(h) down(2.5) fillet(l=h, r=dOuter/2, spin=0, orient=BOTTOM)
                    back(dOuter) xrot(180) fillet(l=h, r=dOuter/2, spin=0, orient=TOP);
                }
    }
}   