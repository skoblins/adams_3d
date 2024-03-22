// // potentially for "A" pipe!
// variants_reed_pipe_length = 60;
// variants_reed_pipe_in_diameter = 6.5;

// // Alpha state - this plays!
// variants_reed_pipe_length = 45;
// variants_reed_pipe_end_length = 12.5; // -> old value: 0.25 * variants_reed_pipe_length
// echo(str("variants_reed_pipe_end_length: ", variants_reed_pipe_end_length));
// variants_reed_pipe_in_diameter = 6.5;
// variants_reed_pipe_cut_prcnt = 11; // 11 -> plays good, 12 -> a bit hard
// variants_reed_pipe_leaf_degree = 1.65;
// variants_pipe_leaf_stem_heigth_coeff_init = 0.025;
// variants_pipe_leaf_stem_heigth_coeff = 0.010;


// was working quite quite...
// variants_reed_pipe_length = 45;
// variants_reed_pipe_fastener_length = variants_reed_pipe_length / 10;
// variants_reed_pipe_end_length = 12.5; // -> old value: 0.25 * variants_reed_pipe_length
// echo(str("variants_reed_pipe_end_length: ", variants_reed_pipe_end_length));
// variants_reed_pipe_in_diameter = 7;
// variants_reed_pipe_wall_thickness = 0.8;
// variants_reed_pipe_cut_prcnt = 11;
// variants_reed_pipe_leaf_degree = 1.7;
// variants_pipe_leaf_stem_heigth_coeff_init = 0.025;
// variants_pipe_leaf_stem_heigth_coeff = 0.010;

// This set has potential to play in "C" (the topmost and the bottom holes play "~~C")
// reed plays easilly, no force required. GO LINEAR, in general...
// material: Prusament PLA Black Galaxy
// noozle = 0.25
// variants_reed_pipe_length = 52;
// variants_reed_pipe_fastener_length = variants_reed_pipe_length * 0.13;
// variants_reed_pipe_end_length = 15;
// variants_reed_pipe_in_diameter = 8;
// variants_reed_pipe_wall_thickness = 0.8;
// variants_reed_pipe_cut_prcnt = 11;
// variants_reed_pipe_leaf_degree = 1.64; // 1.66 gives lower tone!
// variants_leaf_enforcement_square_coeff = 0.000;
// variants_leaf_enforcement_linear_coeff = 0.04;
// variants_leaf_enforcement_const_coeff = 0.4;
// variants_leaf_enforcement_support_stem_height = 0.8;

variants_reed_pipe_length = 50;
variants_reed_pipe_fastener_length = variants_reed_pipe_length * 0.13;
variants_reed_pipe_end_length = 15;
variants_reed_pipe_in_diameter = 8;
variants_reed_pipe_wall_thickness = 0.8;
variants_reed_pipe_cut_prcnt = 11;
variants_reed_pipe_leaf_degree = 1.64; // 1.66 gives lower tone!


// leaf only
// variants_leaf_thickness = 0.4;
variants_leaf_enforcement_square_coeff = 0.000;
variants_leaf_enforcement_linear_coeff = 0.04;
variants_leaf_enforcement_const_coeff = 0.45;
variants_leaf_enforcement_support_stem_height = 0;
