include <reed/reed_2_0_0.scad>
include <reed/tools.scad>
include <variants-reed-pipe.scad>

$fn=100;

arrange(spacing = 15, n = 3){
    // reed2(
    //     variants_reed_pipe_length,
    //     variants_reed_pipe_end_length,
    //     variants_reed_pipe_in_diameter,
    //     variants_reed_pipe_cut_prcnt,
    //     1.575
    // );
    // reed2(
    //     72,
    //     variants_reed_pipe_end_length,
    //     variants_reed_pipe_in_diameter,
    //     variants_reed_pipe_cut_prcnt,
    //     1.60
    // );
    arrange(spacing = 38, n = 3){
        reed2(
            variants_reed_pipe_length,
            variants_reed_pipe_end_length,
            variants_reed_pipe_in_diameter,
            variants_reed_pipe_cut_prcnt,
            variants_reed_pipe_leaf_degree
        );

        %translate([0, 0, variants_reed_pipe_end_length]) leaf21(
            l = 48,
            leaf_enforcement_square_coeff = 0,
            leaf_enforcement_linear_coeff = 0.025,
            leaf_enforcement_const_coeff = 0.4,
            leaf_enforcement_support_stem_height = 0
        );
    }
}
