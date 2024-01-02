lengths = [60, 65, 70];
diameters = [5, 6, 7];
// diameters = [6];

heigth_cut_prcnt = [11:1:13];
// heigth_cut_prcnt = [11];
leaf_degrees = [0.8:0.2:1.2];
// leaf_degrees = [1];

variants2 = [for(l=lengths) for(d=diameters) for(h=heigth_cut_prcnt) for(ld=leaf_degrees) [l, l/80*20, d, h, ld]];
echo(str("There is ", len(variants2), "reed2 variants"));

variants_leaf2 = [for(l=lengths) for(d=diameters) for(h=heigth_cut_prcnt) [l, l/80*20, d, h]];
echo(str("There is ", len(variants_leaf2), "leaf2 variants"));
