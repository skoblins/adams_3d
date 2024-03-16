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


variants_reed_pipe_length = 50;
variants_reed_pipe_fastener_length = variants_reed_pipe_length * 0.13;
variants_reed_pipe_end_length = 15; // -> old value: 0.25 * variants_reed_pipe_length
variants_reed_pipe_in_diameter = 8;
variants_reed_pipe_wall_thickness = 0.8;
variants_reed_pipe_cut_prcnt = 11;
variants_reed_pipe_leaf_degree = 1.65;
variants_pipe_leaf_stem_heigth_coeff_init = 0.025;
variants_pipe_leaf_stem_heigth_coeff = 0.010;

// leaf only
variants_leaf_thickness = 0.4;
variants_leaf_enforcement_square_coeff = 0.0014;
variants_leaf_enforcement_linear_coeff = 0.01;
variants_leaf_enforcement_const_coeff = 0.4;
variants_leaf_enforcement_zoffset = 0/*-length * 0.2*/;
