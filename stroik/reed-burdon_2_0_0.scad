include <reed/reed_2_0_0.scad>
include <reed/tools.scad>
include <variants-reed-burdon.scad>

$fn=100;

max_in_a_row = 2;

arrange(spacing = 15, n = 3){
    reed2(
        70,
        variants_reed_pipe_end_length,
        variants_reed_pipe_in_diameter,
        variants_reed_pipe_cut_prcnt,
        1.55
    );
    // reed2(
    //     70,
    //     variants_reed_pipe_end_length,
    //     variants_reed_pipe_in_diameter,
    //     variants_reed_pipe_cut_prcnt,
    //     1.5
    // );
    // reed2(
    //     74,
    //     variants_reed_pipe_end_length,
    //     variants_reed_pipe_in_diameter,
    //     variants_reed_pipe_cut_prcnt,
    //     1.60
    // );
}
