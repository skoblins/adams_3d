include <reed/pipe.scad>
include <variants-pipe.scad>
include <variants-reed-pipe.scad>

$fn=100;

pipe(l=varniants_pipe_len, d=variants_pipe_in_d, reed_d_in=variants_reed_pipe_in_diameter, thickness=variants_pipe_thickness, holes=[[0.1, 8/8], [0.24, 7/8], [0.37, 5/8], [0.44, 6/8], [0.52, 6/8], [0.66, 6/8], [0.78, 5/8], [0.89, 5/8], [0.97, 4/8]]);
