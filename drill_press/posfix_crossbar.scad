use <bearings/tooth_linear.scad>
include <connectors/lin_screw.scad>

include <BOSL2/std.scad>

// Example values
crossbar_length = 100;
crossbar_snap_thickness = 5;
rail_height = 5;
rail_tooth_length = 2;
clearance = 0.6;



module posfix_crossbar_snap(length, width, height, tooth_length, anchor = CENTER, spin = 0, orient = UP) {
    eps = 0.01;
    snap_l = length/5;
    arm_len = width;
    attachable(anchor = anchor, spin = spin, orient = orient, size = [length + clearance - eps, 5 * width + clearance - eps, height]) {
        union() {
            linear_tooth_bearing_complement(snap_l, width - clearance, height, tooth_length)
                align(TOP) {
                    cylinder(h = height + 3*clearance, d = width - clearance, $fn = 50)
                    align(TOP) cuboid([3*(width - clearance), 3*(width - clearance), 2*width], chamfer = min(height, width)/3, $fn = 50);
                }
            
            up(height/4) {
                fwd(width + clearance/2) cuboid([snap_l + clearance, width + clearance, height/2])
                {
                    align(TOP, BACK)
                        cuboid([snap_l + width/2 + clearance, width / 4 + clearance, height + eps], chamfer = min(height, width)/5, edges = [FRONT+RIGHT, FRONT+LEFT]);
                    fwd(width/2) attach(TOP) cuboid([snap_l + 2*(width) + clearance, arm_len, 2 * height], anchor = TOP+BACK, chamfer = min(height, width)/4, edges = "Y");
                }

                right(snap_l*1/2 + 4*clearance) zrot(90) cuboid([3 * width + 2*clearance, width + clearance - eps, height/2], chamfer = min(height, width)/4, edges = [TOP+FRONT])
                align(TOP, BACK)
                    cuboid([width, width / 4 + clearance, height + eps])
                        zrot(180) align(TOP, BACK) cuboid([width * 3/2 + 2 * clearance, width / 4, 3/2*width + eps], orient = FRONT, spin=0, chamfer = min(height, width)/5, edges = [BACK, BOTTOM+RIGHT, BOTTOM+LEFT]);

                left(snap_l*1/2 + width/2) zrot(90) cuboid([3 * width + 2*clearance, width + clearance - eps, height/2], chamfer = min(height, width)/4, edges = [TOP+BACK])
                align(TOP, FRONT)
                    cuboid([width, width / 4 + clearance, height + eps])
                        align(TOP, BACK) cuboid([width * 3/2 + 2 * clearance, width / 4, 3/2*width + eps], orient = FRONT, spin=0, chamfer = min(height, width)/5, edges = [BACK, BOTTOM+RIGHT, BOTTOM+LEFT]);

                back(width + clearance/2) cuboid([snap_l + clearance, width + clearance, height/2]) {
                    align(TOP, FRONT)
                        cuboid([snap_l + width/2 + clearance, width / 4 + clearance, height + eps], chamfer = min(height, width)/5, edges = [BACK+RIGHT, BACK+LEFT]);
                    back(width/2) attach(TOP) cuboid([snap_l + 2*(width) + clearance, arm_len, 2 * height], anchor = TOP+FRONT, chamfer = min(height, width)/4, edges = "Y")
                        fwd(width) attach(BOTTOM, TOP, align = [BACK], inside = true) cuboid([snap_l + 2 * width, 3 * width + clearance + eps, height/2 - clearance], chamfer = min(height, width)/4, edges = "Y", except=[BOTTOM]);
                }
            }
        }
        children();
    }
}



%posfix_crossbar_rail(length = crossbar_length, width = crossbar_snap_thickness, height = rail_height, tooth_length = rail_tooth_length);
up(rail_height/2 + clearance/2) {
    posfix_crossbar_snap(length = crossbar_length, width = crossbar_snap_thickness, height = rail_height, tooth_length = rail_tooth_length) {
    down(rail_height/2) attach(FRONT, RIGHT) antibend_rod_conn(length = 50, width = crossbar_length/5 + 2 * crossbar_snap_thickness, heigth = 2 * crossbar_snap_thickness, screw_d = 3, screw_head_d = 3, nut_h = 2, nut_d = 5.5);
    }
}
