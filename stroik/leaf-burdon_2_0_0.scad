include <reed/reed_2_0_0.scad>
include <reed/tools.scad>
include <variants-reed-burdon.scad>

$fn=600;

arrange(spacing = 80, n = 3){
    rotate([0, -90, 0]) {
        leaf21(
            l = variants_reed_pipe_length,
            leaf_enforcement_square_coeff = variants_leaf_enforcement_square_coeff,
            leaf_enforcement_linear_coeff = variants_leaf_enforcement_linear_coeff,
            leaf_enforcement_const_coeff = variants_leaf_enforcement_const_coeff,
            leaf_enforcement_support_stem_height = variants_leaf_enforcement_support_stem_height
        );
    }
}
