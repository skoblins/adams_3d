include <reed/reed.scad>
include <variants.scad>

$fn=50;

heigth_cut_prcnt = [12];
leaf_degrees = [1];
variants2 = [for(l=lengths) for(d=diameters) for(h=heigth_cut_prcnt) for(ld=leaf_degrees) [l, l/80*20, d, h, ld]];

max_in_a_row = 6;

for (i = [0:len(variants2)-1]){
    v = variants2[i];
    echo(str("variant: ", v));
    translate([(i%max_in_a_row)*12, (floor(i/max_in_a_row))*12, 0]){
        reed2(v[0], v[1], v[2], v[3], v[4]);
    }
}
