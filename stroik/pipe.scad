include <reed/pipe.scad>
include <variants-pipe.scad>
include <variants-reed-pipe.scad>

$fn=100;

%pipe(l=variants_pipe_len, d_in=variants_pipe_in_d, reed_d_in=variants_reed_pipe_in_diameter, thickness_bottom=variants_pipe_thickness_bottom, thickness_top=variants_pipe_thickness_top, holes=[[0.1, 4/8], [0.23, 8/8], [0.37, 5/8], [0.44, 6/8], [0.52, 7/8], [0.66, 6/8], [0.78, 5/8], [0.89, 5/8], [0.97, 5/8]]);

entire_support_h = variants_pipe_len/2;
first_support_point = horn_plug_len;
support_point_distance = entire_support_h/4;

function calculate_support_horiz_extent(z) = entire_support_h - z/entire_support_h

translate([variants_pipe_thickness_bottom+variants_pipe_in_d/2+0.8,0,0]) rotate([90,0,0]) linear_extrude(height=0.4) polygon(points=[[0,0], [0,first_support_point], [], [variants_pipe_len/5,0],[0,variants_pipe_len/2], [0,0]]);
