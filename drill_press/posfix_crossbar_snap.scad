include <bearings/tooth_linear.scad>
include <connectors/lin_screw.scad>
include <BOSL2/std.scad>

// Example values
// rail
rail_length = 100;
rail_width = 30;
rail_height = 10;
rail_tooth_length = 2;
tooth_height_coeff = 0.66;

// snap
snap_length = 35;
snap_width = rail_width * 1.5;
snap_height = rail_height * 1.5;

// general
clearance = 0.6;
eps = 0.1;

module posfix_crossbar_rail(length, width, height, tooth_length, tooth_height_coeff = 0.5, anchor = CENTER, spin = 0, orient = UP) {
    clearance = 1;
    attachable() {
        cuboid([length, 0.25*width, height])
            fwd(width/4) align(FRONT) linear_tooth_bearing(length, 0.5*width, height, tooth_length, tooth_height_coeff)
                fwd(width/8)align(FRONT) cuboid([length, 0.25*width, height]);
        children();
    }
}

module posfix_crosbar_snap() {
    diff("remove", "keep")
        cuboid([snap_width, snap_length, snap_height]) {
            align(RIGHT) antibend_rod_conn(length = 80, width = snap_length, heigth = snap_height, screw_d = 3, screw_head_h = 3, screw_head_d = 5.5, nut_h = 2, nut_d = 5.5)
            align(TOP,CENTER+LEFT, inside=true) {
                tag("keep")cuboid([80/3, 10, (snap_height-rail_height)/2])
                tag("remove") left((snap_width-rail_width)/2+eps) align(TOP, RIGHT, inside=true) cuboid([80/3, 10+1, snap_height/4+eps]);
            }
            
            align(LEFT, TOP) cuboid([snap_width/2, snap_length, (snap_height-rail_height)/2]);
            tag("remove") cuboid([rail_width + clearance, snap_length + clearance, rail_height+clearance])
            tag("keep") align(TOP, CENTER, inside=true) zrot(90) linear_tooth_complement(length = snap_length*0.75, width = rail_width, height = rail_height, tooth_length = rail_tooth_length, tooth_height_coeff = tooth_height_coeff, spin = 0)
            {
                align(TOP, BACK) cuboid([10, snap_width, (snap_height-rail_height-clearance)/2])
                    tag("remove") cuboid([10+1 , snap_width+1, (snap_height-rail_height-clearance+eps)/2]);
                align(TOP) cuboid([snap_length*0.75, rail_width/2, (snap_height-rail_height-clearance)/2, rail_tooth_length])
                    up(eps) tag("remove") cuboid([snap_length*0.75+1, rail_width/2+1, (snap_height-rail_height)/2]);
                align(TOP, FRONT) cuboid([10, (snap_width+rail_width)/2 + 2, (snap_height-rail_height-clearance)/2]) {
                    tag("remove") cuboid([10+1, (snap_width+rail_width)/2 + 2, (snap_height-rail_height+eps)/2]);
                    back(1) down(clearance/4) align(CENTER,BACK) cuboid([snap_length, 2, (snap_height-rail_height)/2])
                        tag("remove") align(BACK, inside=true) cuboid([snap_length+1, 2+1, (snap_height-rail_height)/2+eps]);
                }
            }
            // screws
            // snap
            up(eps/2) {
                tag("remove") back(snap_length/8) right((snap_width-rail_width)/4-3/2) align(TOP, LEFT+FRONT, inside=true) 
                    zcyl(d = 3 + clearance, h = snap_height + eps, $fn = 50) {
                        align(TOP, inside=true) zcyl(d = 5.5 + clearance, h = 3 + eps, $fn = 50);
                        align(BOTTOM, inside=true) cuboid([5.5 + clearance, 5.5 + clearance, 2 + clearance]);
                    }
                tag("remove") fwd(snap_length/8) right((snap_width-rail_width)/4-3/2) align(TOP, LEFT+BACK, inside=true)
                    zcyl(d = 3 + clearance, h = snap_height + eps, $fn = 50) {
                        align(TOP, inside=true) zcyl(d = 5.5 + clearance, h = 3 + eps, $fn = 50);
                        align(BOTTOM, inside=true) cuboid([5.5 + clearance, 5.5 + clearance, 2 + clearance]);
                    }
                tag("remove") fwd(snap_length/8) left((snap_width-rail_width)/4-3/2) align(TOP, RIGHT+BACK, inside=true)
                    zcyl(d = 3 + clearance, h = snap_height + eps, $fn = 50) {
                        align(TOP, inside=true) zcyl(d = 5.5 + clearance, h = 3 + eps, $fn = 50);
                        align(BOTTOM, inside=true) cuboid([5.5 + clearance, 5.5 + clearance, 2 + clearance]);
                    }
                tag("remove") back(snap_length/8) left((snap_width-rail_width)/4-3/2) align(TOP, RIGHT+FRONT, inside=true)
                    zcyl(d = 3 + clearance, h = snap_height + eps, $fn = 50) {
                        align(TOP, inside=true) zcyl(d = 5.5 + clearance, h = 3 + eps, $fn = 50);
                        align(BOTTOM, inside=true) cuboid([5.5 + clearance, 5.5 + clearance, 2 + clearance]);
                    }
                // crossbar
                tag("remove") back(snap_length/8) right(80-((snap_width-rail_width)/4-3/2)) align(TOP, RIGHT+FRONT, inside=true)
                    zcyl(d = 3 + clearance, h = snap_height + eps, $fn = 50) {
                        align(TOP, inside=true) zcyl(d = 5.5 + clearance, h = 3 + eps, $fn = 50);
                        align(BOTTOM, inside=true) cuboid([5.5 + clearance, 5.5 + clearance, 2 + clearance]);
                    }
                tag("remove") fwd(snap_length/8) right(80-((snap_width-rail_width)/4-3/2)) align(TOP, RIGHT+BACK, inside=true)
                    zcyl(d = 3 + clearance, h = snap_height + eps, $fn = 50) {
                        align(TOP, inside=true) zcyl(d = 5.5 + clearance, h = 3 + eps, $fn = 50);
                        align(BOTTOM, inside=true) cuboid([5.5 + clearance, 5.5 + clearance, 2 + clearance]);
                    }
            }

        }
}

intersect("mask") {
    posfix_crosbar_snap();
    tag("mask") up(snap_height/4) right(snap_width) cuboid([4*snap_width+80+eps, snap_length+eps, snap_height/2+eps]);
}

!down(25) difference() {
    posfix_crosbar_snap();
    up(snap_height/4) right(snap_width) cuboid([4*snap_width+80+eps, snap_length+eps, snap_height/2+eps]);
}

back(50) posfix_crossbar_rail(length = rail_length, width = rail_width, height = rail_height, tooth_length = rail_tooth_length, tooth_height_coeff = tooth_height_coeff);