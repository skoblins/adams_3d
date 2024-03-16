include <reed/reed_2_0_0.scad>
include <variants-reed-pipe.scad>

$fn=100;

%translate([20, 20, 0]) reed2_leaf( variants_reed_pipe_length,
            variants_reed_pipe_end_length,
            variants_reed_pipe_in_diameter,
            variants_reed_pipe_cut_prcnt,
            variants_pipe_leaf_stem_heigth_coeff_init,
            variants_pipe_leaf_stem_heigth_coeff
);

leaf21();
