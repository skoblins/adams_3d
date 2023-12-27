// lengths = [65, 70, 75];
// diameters = [4, 5, 6, 7, 8];

// lengths = [65, 70];
// diameters = [5, 6];

lengths = [65];
// diameters = [5, 6, 7];
diameters = [6];

variants = [for(l=lengths) for(d=diameters) [l, l/80*20, 1, d, l/80*0.9, 1.5, [0.75,0.3,3,0.4]] ];

///////////////////
// For reed 2.0! //
///////////////////

heigth_cut_prcnt = [10:1:15];
leaf_degrees = [0.4:0.2:1.2];
variants2 = [for(l=lengths) for(d=diameters) for(h=heigth_cut_prcnt) for(ld=leaf_degrees) [l, l/80*20, d, h, ld]];

echo(str("There is ", len(variants2), " variants"));
