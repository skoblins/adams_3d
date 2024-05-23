include <variants-pipe.scad>

$fn = 200;

h1 = 30;
h2 = 101;

d_out1 = variants_pipe_in_d + 4;
d_out2 = variants_pipe_in_d * 1.3 + 4;
d_out3 = 50;

module outside() {
cylinder(h = h1, d1 = d_out2, d2 = d_out1);

translate ([0, 0, -(h2 - 1)]) {
hull() {
    translate([0, 0, h2 * 0.75]) sphere(d = d_out3);
    translate([0, 0, 30]) cube([variants_pipe_plug_stopper_d + 1, variants_pipe_plug_stopper_d + 1, 10], true);
}
hull() {
    translate([0, 0, 30]) cube([variants_pipe_plug_stopper_d + 1, variants_pipe_plug_stopper_d + 1, 10], true);
    cylinder(h = 10, d = variants_pipe_plug_stopper_d);
}
}
}

module inside() {
cylinder(h = h1 + 1, d1 = d_out2 - 4, d2 = d_out1 - 4);

translate ([0, 0, -(h2 - 1)]) {
hull() {
    translate([0, 0, h2 * 0.75]) sphere(d = d_out3 - 4);
    translate([0, 0, pipe_plug_len]) cube([variants_pipe_plug_stopper_d - 4, variants_pipe_plug_stopper_d - 4, 10], true);
}
 translate([0, 0, -0.5]) cylinder(h = pipe_plug_len + 1, d = variants_pipe_plug_out_d + 2);
}
}

difference() {
    outside();
    inside();
}