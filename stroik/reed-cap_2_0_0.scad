include <reed/reed_2_0_0.scad>
include <variants-burdon_2_0_0.scad>
include <variants-pipe_2_0_0.scad>

// variants = variants_pipe;
variants = variants_burdon;

$fn=100;

max_in_a_row = 2;

for (i = [0:len(variants)-1]){
    v = variants[i];
    echo(str("variant: ", v));
    translate([(i%max_in_a_row)*v[1], (i/max_in_a_row)*v[1], 0]){
        reed2_end_cap(v[0], v[1], v[2], v[3], v[4]);
    }
}