include <reed/reed_2_0_0.scad>
include <variants-reed-burdon.scad>

$fn=100;

max_in_a_row = 2;

reed2(variants_reed_pipe_length, variants_reed_pipe_end_length, variants_reed_pipe_in_diameter, variants_reed_pipe_cut_prcnt, variants_reed_pipe_leaf_degree);
