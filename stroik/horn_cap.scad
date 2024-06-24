include <constructive/constructive-compiled.scad>
include <variants-pipe.scad>

$fn = 100;

module horn_cap(cap_out_d = 62, scale_x_coeff = 1.15, scale_y_coeff = 0.85, hole_d = 16, h = 4) {
    stack() {
        TOUP() {
            cscale(x = scale_x_coeff, y = scale_y_coeff) tube(h = 1, dInner = hole_d, dOuter = cap_out_d)
            tube(h = h, d = cap_out_d, wall = 1);
        }
    }

}

horn_cap(cap_out_d = 65, hole_d = 16, h = 4);
translate([80,0,0]) horn_cap(cap_out_d = 52, scale_x_coeff = 1, scale_y_coeff = 1, hole_d = 16, h = 5);
