// lengths = [65, 70, 75];
// diameters = [4, 5, 6, 7, 8];

// lengths = [65, 70];
// diameters = [5, 6];

lengths = [60];
// diameters = [5, 6, 7];
diameters = [6];


heigth_cut_prcnt = [10];
leaf_degrees = [1.6];
variants_pipe = [for(l=lengths) for(d=diameters) for(h=heigth_cut_prcnt) for(ld=leaf_degrees) [l, l/100*25, d, h, ld]];

variants_pipe_leaf_stem_heigth_coeff_init = 0.035;
variants_pipe_leaf_stem_heigth_coeff = 0.025;
