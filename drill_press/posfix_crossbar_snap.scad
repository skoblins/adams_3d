include <bearings/tooth_linear.scad>
include <connectors/lin_screw.scad>
include <BOSL2/std.scad>

module posfix_crossbar_rail(length, width, height, tooth_length, tooth_height_coeff = 0.5, anchor = CENTER, spin = 0, orient = UP) {
    clearance = 1;
    attachable(cp = [(tooth_length + clearance/2)/2, -(0.25+0.5)/2*width, 0], size = [length + tooth_length + clearance/2, width, height], anchor = anchor, spin = spin, orient = orient) {
        cuboid([length, 0.25*width, height])
            fwd(width/4) align(FRONT) linear_tooth_bearing(length, 0.5*width, height, tooth_length, tooth_height_coeff)
                fwd(width/8)align(FRONT) cuboid([length, 0.25*width, height]);
        children();
    }
}

module posfix_crossbar_rail_right(length, width, height, tooth_length, tooth_height_coeff = 0.5, anchor = CENTER, spin = 0, orient = UP) {
    clearance = 1;
    attachable(cp = [(tooth_length + clearance/2)/2, -(0.25+0.5)/2*width, 0], size = [length + tooth_length + clearance/2, width, height], anchor = anchor, spin = spin, orient = orient) {
        cuboid([length, 0.25*width, height])
            fwd(width/4) align(FRONT) linear_tooth_bearing(length, 0.5*width, height, tooth_length, tooth_height_coeff)
                fwd(width/8)align(FRONT) cuboid([length, 0.25*width, height]);
        children();
    }
}

module posfix_crossbar_rail_with_connector(length = 100, width = 30, height = 10, tooth_length = 2, tooth_height_coeff = 0.66, connector_length = 50, nut_height = 8, nut_width = 3, screw_d = 5, screw_head_h = 5, screw_head_d = 8.5, clearance = 0.4) {
    fwd(50) posfix_crossbar_rail(length = length, width = width, height = height, tooth_length = tooth_length, tooth_height_coeff = tooth_height_coeff) {
        left(tooth_length+clearance+_eps) align(RIGHT+CENTER) segment_with_square_nuts(length = connector_length, height = height, width = width, screw_head_h = screw_head_h, screw_head_d = screw_head_d, screw_d = screw_d, nut_height = nut_height, nut_width = nut_width, clearance = 0.2);
        align(LEFT+CENTER) segment_compliment_with_bolts(length = connector_length, height = height, width = width, screw_head_h = screw_head_h, screw_head_d = screw_head_d, screw_d = screw_d, nut_height = nut_height, nut_width = nut_width, clearance = 0.2);
    }
}

module posfix_crossbar_rail_right_with_connector(length = 100, width = 30, height = 10, tooth_length = 2, tooth_height_coeff = 0.66, connector_length = 50, nut_height = 8, nut_width = 3, screw_d = 5, screw_head_h = 5, screw_head_d = 8.5, clearance = 0.4) {
    posfix_crossbar_rail_right(length = length, width = width, height = height, tooth_length = tooth_length, tooth_height_coeff = tooth_height_coeff) {
        /*right(tooth_length+clearance+_eps)*/ align(LEFT+CENTER) segment_with_square_nuts(length = connector_length, height = height, width = width, screw_head_h = screw_head_h, screw_head_d = screw_head_d, screw_d = screw_d, nut_height = nut_height, nut_width = nut_width, clearance = 0.2);
        left(tooth_length+clearance+_eps) align(RIGHT+CENTER) segment_compliment_with_bolts(length = connector_length, height = height, width = width, screw_head_h = screw_head_h, screw_head_d = screw_head_d, screw_d = screw_d, nut_height = nut_height, nut_width = nut_width, clearance = 0.2);
    }
}

module posfix_crosbar_snap(center_connector_length = 80, snap_length = 35, snap_width = 45, snap_height = 15, rail_length = 100, rail_width = 30, rail_height = 10, rail_tooth_length = 2, tooth_height_coeff = 0.66, clearance = 0.6, eps = 0.01) {
    diff("remove", "keep")
        cuboid([snap_width, snap_length, snap_height]) {
            align(RIGHT) antibend_rod_conn(length = center_connector_length, width = snap_length, height = snap_height, screw_d = 3.5, screw_head_h = 3, screw_head_d = 5.5, nut_h = 2, nut_d = 5.5)
            align(TOP,CENTER+LEFT, inside=true, inset = -snap_height/4) {
                tag("keep")cuboid([center_connector_length/3, 10, (snap_height-rail_height)/2]);
                tag("remove") cuboid([center_connector_length/2+eps, 10+1, snap_height/4+eps]);
            }
            
            align(LEFT, TOP) cuboid([snap_width/2, snap_length, (snap_height-rail_height)/2]);
            tag("remove") cuboid([rail_width + clearance, snap_length + clearance, rail_height+clearance])
            tag("keep") align(TOP, CENTER, inside=true) zrot(90) linear_tooth_complement(length = snap_length*0.75, width = rail_width, height = rail_height, tooth_length = rail_tooth_length, tooth_height_coeff = tooth_height_coeff, spin = 0)
            {
                align(TOP, BACK) cuboid([10, snap_width*1.15, (snap_height-rail_height-clearance)/2])
                    tag("remove") cuboid([10+1, snap_width*1.15, snap_height/2]);
                align(TOP) cuboid([snap_length*0.75, rail_width/2, (snap_height-rail_height-clearance)/2, rail_tooth_length])
                    up(eps) tag("remove") cuboid([snap_length*0.75+1, rail_width/2+1, (snap_height-rail_height)/2]);
                align(TOP, FRONT) cuboid([10, (snap_width+rail_width)/2 + 2, (snap_height-rail_height-clearance)/2]) {
                    tag("remove") cuboid([10+1, (snap_width+rail_width)/2 + 2, (snap_height-rail_height+4)/2]);
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
                tag("remove") back(snap_length/8) right(center_connector_length-((snap_width-rail_width)/4-3/2)) align(TOP, RIGHT+FRONT, inside=true)
                    zcyl(d = 3 + clearance, h = snap_height + eps, $fn = 50) {
                        align(TOP, inside=true) zcyl(d = 5.5 + clearance, h = 3 + eps, $fn = 50);
                        align(BOTTOM, inside=true) cuboid([5.5 + clearance, 5.5 + clearance, 2 + clearance]);
                    }
                tag("remove") fwd(snap_length/8) right(center_connector_length-((snap_width-rail_width)/4-3/2)) align(TOP, RIGHT+BACK, inside=true)
                    zcyl(d = 3 + clearance, h = snap_height + eps, $fn = 50) {
                        align(TOP, inside=true) zcyl(d = 5.5 + clearance, h = 3 + eps, $fn = 50);
                        align(BOTTOM, inside=true) cuboid([5.5 + clearance, 5.5 + clearance, 2 + clearance]);
                    }
            }

        }
}

module posfix_crosbar_snap_right(center_connector_length = 80, snap_length = 35, snap_width = 45, snap_height = 15, rail_length = 100, rail_width = 30, rail_height = 10, rail_tooth_length = 2, tooth_height_coeff = 0.66, clearance = 0.6, eps = 0.01) {
    diff("remove", "keep")
        cuboid([snap_width, snap_length, snap_height]) {
            align(RIGHT) antibend_rod_conn(length = center_connector_length, width = snap_length, height = snap_height, screw_d = 3.5, screw_head_h = 3, screw_head_d = 5.5, nut_h = 2, nut_d = 5.5)
            align(TOP,CENTER+LEFT, inside=true) {
                tag("keep")cuboid([center_connector_length/3, 10, (snap_height-rail_height)/2])
                tag("remove") left((snap_width-rail_width)/2+eps) align(TOP, RIGHT, inside=true) cuboid([center_connector_length/3, 10+1, snap_height/4+eps]);
            }
            
            align(LEFT, TOP) cuboid([snap_width/2, snap_length, (snap_height-rail_height)/2]);
            tag("remove") cuboid([rail_width + clearance, snap_length + clearance, rail_height+clearance])
            tag("keep") align(TOP, CENTER, inside=true) zrot(90+180) linear_tooth_complement(length = snap_length*0.75, width = rail_width, height = rail_height, tooth_length = rail_tooth_length, tooth_height_coeff = tooth_height_coeff, spin = 0)
            zrot(-180) {
                align(TOP, BACK) cuboid([10, snap_width*1.15, (snap_height-rail_height-clearance)/2])
                    tag("remove") cuboid([10+1, snap_width*1.15, snap_height/2]);
                align(TOP) cuboid([snap_length*0.75, rail_width/2, (snap_height-rail_height-clearance)/2, rail_tooth_length])
                    up(eps) tag("remove") cuboid([snap_length*0.75+1, rail_width/2+1, (snap_height-rail_height)/2]);
                align(TOP, FRONT) cuboid([10, (snap_width+rail_width)/2 + 2, (snap_height-rail_heightprev-clearance)/2]) {
                    tag("remove") cuboid([10+1, (snap_width+rail_width)/2 + 2, (snap_height-rail_height+4)/2]);
                    back(1) down(clearance/4) align(CENTER, BACK) cuboid([snap_length, 2, (snap_height-rail_height)/2])
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
                tag("remove") back(snap_length/8) right(center_connector_length-((snap_width-rail_width)/4-3/2)) align(TOP, RIGHT+FRONT, inside=true)
                    zcyl(d = 3 + clearance, h = snap_height + eps, $fn = 50) {
                        align(TOP, inside=true) zcyl(d = 5.5 + clearance, h = 3 + eps, $fn = 50);
                        align(BOTTOM, inside=true) cuboid([5.5 + clearance, 5.5 + clearance, 2 + clearance]);
                    }
                tag("remove") fwd(snap_length/8) right(center_connector_length-((snap_width-rail_width)/4-3/2)) align(TOP, RIGHT+BACK, inside=true)
                    zcyl(d = 3 + clearance, h = snap_height + eps, $fn = 50) {
                        align(TOP, inside=true) zcyl(d = 5.5 + clearance, h = 3 + eps, $fn = 50);
                        align(BOTTOM, inside=true) cuboid([5.5 + clearance, 5.5 + clearance, 2 + clearance]);
                    }
            }

        }
}

module posfix_crossbar_snap_upper(center_connector_length, snap_length, snap_width, snap_height, rail_length, rail_width, rail_height, rail_tooth_length, tooth_height_coeff, clearance, eps) {
    intersect("mask") {
        posfix_crosbar_snap(center_connector_length = center_connector_length, snap_length = snap_length, snap_width = snap_width, snap_height = snap_height, rail_length = rail_length, rail_width = rail_width, rail_height = rail_height, rail_tooth_length = rail_tooth_length, tooth_height_coeff = tooth_height_coeff, clearance = clearance);
        tag("mask") up(snap_height/4) right(snap_width) cuboid([4*snap_width+80+eps, snap_length+eps, snap_height/2+eps]);
    }
}

module posfix_crossbar_snap_right_upper(center_connector_length, snap_length, snap_width, snap_height, rail_length, rail_width, rail_height, rail_tooth_length, tooth_height_coeff, clearance, eps) {
    intersect("mask") {
        posfix_crosbar_snap_right(center_connector_length = center_connector_length, snap_length = snap_length, snap_width = snap_width, snap_height = snap_height, rail_length = rail_length, rail_width = rail_width, rail_height = rail_height, rail_tooth_length = rail_tooth_length, tooth_height_coeff = tooth_height_coeff, clearance = clearance);
        tag("mask") up(snap_height/4) right(snap_width) cuboid([4*snap_width+80+eps, snap_length+eps, snap_height/2+eps]);
    }
}

module posfix_crossbar_snap_bottom(center_connector_length, snap_length, snap_width, snap_height, rail_length, rail_width, rail_height, rail_tooth_length, tooth_height_coeff, clearance, eps) {
    difference() {
        posfix_crosbar_snap(center_connector_length, snap_length, snap_width, snap_height, rail_length, rail_width, rail_height, rail_tooth_length, tooth_height_coeff, clearance = 0.2);
        up(snap_height/4) right(snap_width) cuboid([4*snap_width+80+eps, snap_length+eps, snap_height/2+eps]);
    }
}

module posfix_crossbar_snap_right_bottom(center_connector_length, snap_length, snap_width, snap_height, rail_length, rail_width, rail_height, rail_tooth_length, tooth_height_coeff, clearance, eps) {
    difference() {
        posfix_crosbar_snap_right(center_connector_length, snap_length, snap_width, snap_height, rail_length, rail_width, rail_height, rail_tooth_length, tooth_height_coeff, clearance = 0.2);
        up(snap_height/4) right(snap_width) cuboid([4*snap_width+80+eps, snap_length+eps, snap_height/2+eps]);
    }
}
