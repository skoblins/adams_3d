include <BOSL2/linear_bearings.scad>
include <BOSL2/walls.scad>
include <BOSL2/std.scad>

$fn = 100;

linear_bearing_d = 25;
x_size = 200 - linear_bearing_d;

drill_ball_bearing_h = 9;
drill_ball_bearing_d_in = 8;
drill_ball_bearing_d = 28.14;

thickness_coeff = 2;
drill_ball_bearing_embedding_h = drill_ball_bearing_h * thickness_coeff;
drill_ball_bearing_embedding_d = drill_ball_bearing_d * thickness_coeff * 0.8;

d_clearance = 0.5;
h_clearance = 1;
eps = 0.2;

difference() {
    union() {
        cylinder(h = drill_ball_bearing_embedding_h, d = drill_ball_bearing_embedding_d, center = true);
        zrot_copies(n = 4) right(x_size / 4) {
            sparse_cuboid([x_size / 2, drill_ball_bearing_embedding_h, drill_ball_bearing_embedding_h], /*center = true, */strut = 1, max_bridge = 5, rounding = 2, $fn = 8)
            align(RIGHT + TOP) xmove(-2) yrot(90){
                linear_bearing_housing(d = linear_bearing_d, l = drill_ball_bearing_embedding_h, wall = 2, tab = 10, screwsize = 2.5, $fn = 100);
            }
        }
    }
    union() {
        cylinder(h = drill_ball_bearing_h + h_clearance, d = drill_ball_bearing_d + d_clearance, center = true);
        cylinder(h = drill_ball_bearing_embedding_h + eps, d = drill_ball_bearing_d_in + 2, center = true);
    }
}
