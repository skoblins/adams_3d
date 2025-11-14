include <variants-reed-pipe.scad>
include <reed/reed_2_0_0.scad>
include <reed/tools.scad>


$fn=600;

max_in_a_row = 2;

select = 0;

//end_length, d, heigth_cut_prcnt, leaf_degree
arrange(spacing = 15, n = 3){

    if(select == 0 || select == 2) {
        reed2(
            total_length = variants_reed_pipe_length,
            end_length = variants_reed_pipe_end_length,
            entry_d = variants_reed_pipe_entry_in_diameter,
            main_d = variants_reed_pipe_in_diameter,
            heigth_cut_prcnt = variants_reed_pipe_cut_prcnt,
            leaf_degree = variants_reed_pipe_leaf_degree
        );
    }
    if(select == 1 || select == 2) {
        translate([0,0,variants_reed_pipe_end_length]) leaf21(
                l = variants_reed_pipe_length,
                leaf_enforcement_square_coeff = variants_leaf_enforcement_square_coeff,
                leaf_enforcement_linear_coeff = variants_leaf_enforcement_linear_coeff,
                leaf_enforcement_const_coeff = variants_leaf_enforcement_const_coeff,
                leaf_enforcement_support_stem_height = variants_leaf_enforcement_support_stem_height
            );
        }
    // reed2(
    //     74,
    //     variants_reed_pipe_end_length,
    //     variants_reed_pipe_in_diameter,
    //     variants_reed_pipe_cut_prcnt,
    //     1.60
    // );
}
