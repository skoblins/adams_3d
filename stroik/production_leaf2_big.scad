include <reed/reed.scad>
include <variants2.scad>

$fn=100;

lengths = [80];
diameters = [6, 7, 8];
// diameters = [6];

heigth_cut_prcnt = [11, 12];
// heigth_cut_prcnt = [11];
leaf_degrees = [0.8:0.2:1.2];

max_in_a_row = 3;

for (i = [0:len(variants_leaf2)-1]){
    v = variants_leaf2[i];
    echo(str("variant: ", v));
    translate([(i%max_in_a_row)*12, (floor(i/max_in_a_row))*12, 0]){
        reed2_leaf(v[0], v[1], v[2], v[3]);
    }
}