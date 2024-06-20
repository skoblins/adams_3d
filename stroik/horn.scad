include <reed/pipe.scad>
include <variants-pipe.scad>

$fn=100;

//horn(horn_len = 95, horn_degree = 80, horn_twist = 90, horn_d_out_end = 50, resolution = 1);
horn_cap(cap_in_d = 60, cap_out_d = 65, hole_d = 16);
translate([80,0,0]) horn_cap(cap_in_d = 37, cap_out_d = 52, scale_x_coeff = 1, scale_y_coeff = 1, hole_d = 16);
