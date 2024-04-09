include <reed/reed_2_0_0.scad>
include <reed/tools.scad>
include <variants-reed-pipe.scad>

$fn=100;

// %translate([20, 20, 0]) reed2_leaf( variants_reed_pipe_length,
//             variants_reed_pipe_end_length,
//             variants_reed_pipe_in_diameter,
//             variants_reed_pipe_cut_prcnt,
//             variants_pipe_leaf_stem_heigth_coeff_init,
//             variants_pipe_leaf_stem_heigth_coeff
// );

arrange(spacing = 38, n = 3){
        rotate([0, -90, 0]) {
       leaf21(
            l = 48,
            leaf_enforcement_square_coeff = -0.0005,
            leaf_enforcement_linear_coeff = 0.025,
            leaf_enforcement_const_coeff = 0.4,
            leaf_enforcement_support_stem_height = 0
        );
    }
    // reed2(
    //     48,
    //     variants_reed_pipe_end_length,
    //     variants_reed_pipe_in_diameter,
    //     variants_reed_pipe_cut_prcnt,
    //     variants_reed_pipe_leaf_degree
    // );
}
