include <reed/pipe.scad>
include <variants-pipe.scad>
include <variants-reed-pipe.scad>

$fn=100;

pipe(l=varniants_pipe_len, d_in=variants_pipe_in_d, reed_d_in=variants_reed_pipe_in_diameter, thickness_bottom=variants_pipe_thickness_bottom, thickness_top=variants_pipe_thickness_top, holes=[[0.1, 4/8], [0.23, 8/8], [0.37, 5/8], [0.44, 6/8], [0.52, 7/8], [0.66, 6/8], [0.78, 5/8], [0.89, 5/8], [0.97, 5/8]]);
