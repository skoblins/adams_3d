include <reed/reed_2_0_0.scad>
include <variants_2_0_0.scad>

$fn=100;

max_in_a_row = 2;

for (i = [0:len(variants2)-1]){
    v = variants2[i];
    echo(str("variant: ", v));
    translate([(i%max_in_a_row)*v[0]*1.2, (i/max_in_a_row)*v[1], 0]){
        rotate([0, 90, 0]) reed2_leaf(v[0], v[1], v[2], v[3]);
    }
}
