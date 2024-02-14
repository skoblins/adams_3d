include <reed/reed_1_0_0.scad>
include <variants_1_0_0.scad>

$fn=40;

max_in_a_row = 6;

for (i = [0:len(variants)-1]){
    v = variants[i];
    echo(str("variant: ", v));
    translate([(i%max_in_a_row)*12, (floor(i/max_in_a_row))*12, 0]){
        reed(v[0], v[1], v[2], v[3], v[4], v[5], v[6]);
    }
}
