// lengths = [55, 60, 65, 70, 75, 80];
// diameters = [4, 5, 6, 7, 8];

// lengths = [65, 70];
// diameters = [5, 6];

lengths = [65];
diameters = [6];

variants = [for(l=lengths) for(d=diameters) [l, l/80*20, 1, d, l/80*0.9, 1.5, [0.75,0.3,3,0.4]] ];

///////////////////
// For reed 2.0! //
///////////////////

heigth_cut_prcnt = [11, 12, 15];
variants2 = [for(l=lengths) for(d=diameters) for(h=heigth_cut_prcnt) [l, l/80*20, d, h]];
