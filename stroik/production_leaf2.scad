include <reed/reed.scad>
include <variants2.scad>

$fn=100;

max_in_a_row = 5;

for (i = [0:len(variants_leaf2)-1]){
    v = variants_leaf2[i];
    echo(str("variant: ", v));
    translate([(i%max_in_a_row)*12, (floor(i/max_in_a_row))*12, 0]){
        reed2_leaf(v[0], v[1], v[2], v[3]);
    }
}
