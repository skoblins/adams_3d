include <reed/reed_2_0_0.scad>
include <variants-reed-pipe.scad>

$fn=100;

// %translate([20, 20, 0]) reed2_leaf( variants_reed_pipe_length,
//             variants_reed_pipe_end_length,
//             variants_reed_pipe_in_diameter,
//             variants_reed_pipe_cut_prcnt,
//             variants_pipe_leaf_stem_heigth_coeff_init,
//             variants_pipe_leaf_stem_heigth_coeff
// );

module arrange(spacing=50, n=5) {
    nparts = $children;
    for(i=[0:1:n-1], j=[0:nparts/n])
        if (i+n*j < nparts)
            translate([spacing*(i+1), spacing*j, 0])
                children(i+n*j);
 }

 arrange(spacing = 38, n = 3){
    // rotate([0, -90, 0]) {
    //     leaf21(
    //         leaf_enforcement_square_coeff = 0.0014,
    //         leaf_enforcement_linear_coeff = 0.01,
    //         leaf_enforcement_const_coeff = 0.4,
    //         leaf_enforcement_support_stem_height = 1.2
    //     );
    // }
    // rotate([0, -90, 0]) {
    //     leaf21(
    //         leaf_enforcement_square_coeff = 0.0014,
    //         leaf_enforcement_linear_coeff = 0.0,
    //         leaf_enforcement_const_coeff = 0.4,
    //         leaf_enforcement_support_stem_height = 1.2
    //     );
    // }
    // rotate([0, -90, 0]) {
    //     leaf21(
    //         leaf_enforcement_square_coeff = 0.0014,
    //         leaf_enforcement_linear_coeff = 0.01,
    //         leaf_enforcement_const_coeff = 0.2,
    //         leaf_enforcement_support_stem_height = 1.2
    //     );
    // }
    // rotate([0, -90, 0]) {
    //     leaf21(
    //         leaf_enforcement_square_coeff = 0.0010,
    //         leaf_enforcement_linear_coeff = 0.01,
    //         leaf_enforcement_const_coeff = 0.4,
    //         leaf_enforcement_support_stem_height = 1.2
    //     );
    // }
    // rotate([0, -90, 0]) {
    //    leaf21(
    //         leaf_enforcement_square_coeff = 0.0010,
    //         leaf_enforcement_linear_coeff = 0.015,
    //         leaf_enforcement_const_coeff = 0.4,
    //         leaf_enforcement_support_stem_height = 1.2
    //     );
    // }
    // rotate([0, -90, 0]) {
    //     leaf21(
    //         leaf_enforcement_square_coeff = 0.0010,
    //         leaf_enforcement_linear_coeff = 0.01,
    //         leaf_enforcement_const_coeff = 0.6,
    //         leaf_enforcement_support_stem_height = 1.2
    //     );
    // }
    // rotate([0, -90, 0]) {
    //    leaf21(
    //         leaf_enforcement_square_coeff = 0.0010,
    //         leaf_enforcement_linear_coeff = 0.015,
    //         leaf_enforcement_const_coeff = 0.4,
    //         leaf_enforcement_support_stem_height = 0.8
    //     );
    // }
    rotate([0, -90, 0]) {
       leaf21(
            leaf_enforcement_square_coeff = 0.000,
            leaf_enforcement_linear_coeff = 0.035,
            leaf_enforcement_const_coeff = 0.40,
            leaf_enforcement_support_stem_height = 0
        );
    }
}
