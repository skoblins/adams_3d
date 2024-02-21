// lengths = [65, 70, 75];
// diameters = [4, 5, 6, 7, 8];

// lengths = [65, 70];
// diameters = [5, 6];

lengths = [85];
// diameters = [5, 6, 7];
diameters = [10.5];


heigth_cut_prcnt = [12];
leaf_degrees = [1];
variants_burdon = [for(l=lengths) for(d=diameters) for(h=heigth_cut_prcnt) for(ld=leaf_degrees) [l, l/80*20, d, h, ld]];

