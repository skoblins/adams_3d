include <reed/reed_2_0_0.scad>
include <reed/tools.scad>
include <variants-reed-burdon.scad>

$fn=100;

arrange(spacing = 80, n = 3){
    rotate([0, -90, 0]) {
        leaf21(
            l = 72,
            leaf_enforcement_square_coeff = 0.00,
            leaf_enforcement_linear_coeff = 0.04,
            leaf_enforcement_const_coeff = 0.4,
            leaf_enforcement_support_stem_height = 0
        );
    }
    rotate([0, -90, 0]) {
        leaf21(
            l = 74,
            leaf_enforcement_square_coeff = 0.00,
            leaf_enforcement_linear_coeff = 0.04,
            leaf_enforcement_const_coeff = 0.4,
            leaf_enforcement_support_stem_height = 0
        );
    }
}
