include <reed/reed.scad>
include <variants.scad>

$fn=40;

max_in_a_row = 6;

thickness_offsets = [0, 0.1, -0.1];
degree_offsets = [0, 0.2, -0.2];

for (i = [0:len(variants)-1]){
    v = variants[i];
    echo(str("variant: ", v));
    for(th = [0:len(thickness_offsets)-1]) {
        translate([((i*(th+1))%max_in_a_row)*12, (floor((i*(th+1))/max_in_a_row))*12, 0]){
            leaf(v[0], v[1], v[2], v[3]+thickness_offsets[th], v[4], v[5], v[6], degree_offsets[0]);
        }
    }
}