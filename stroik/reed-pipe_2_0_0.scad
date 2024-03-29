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
    }
}
