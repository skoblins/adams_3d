// lengths = [65, 70, 75];
// diameters = [4, 5, 6, 7, 8];

// lengths = [65, 70];
// diameters = [5, 6];

lengths = [70];
// diameters = [5, 6, 7];
diameters = [8];


heigth_cut_prcnt = [10];
leaf_degrees = [1.2];
variants_burdon = [for(l=lengths) for(d=diameters) for(h=heigth_cut_prcnt) for(ld=leaf_degrees) [l, l/100*25, d, h, ld]];

variants_burdon_leaf_stem_heigth_coeff_init = 0.025;
variants_burdon_leaf_stem_heigth_coeff = 0.015;