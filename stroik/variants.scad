lengths = [55, 60, 65, 70, 75, 80];
diameters = [4, 5, 6, 7, 8];

variants = [for(l=lengths) for(d=diameters) [l, l/80*20, 1, d, l/80*0.9, 1.5, [0.75,0.3,3,0.4]] ];
