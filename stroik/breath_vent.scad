include <variants-pipe.scad>

$fn = 100;

cutting_block_w = variants_pipe_plug_out_d + 2;

eps = 0.1;

module cutting_block(thickness = 1) {
    rotate([0, -10, 0]) translate([cutting_block_w/2 + 2, -cutting_block_w / 2, 0]) cube([cutting_block_w, cutting_block_w, variants_breath_pipe_len]);
}

difference() {
    difference() {
        cylinder(h = variants_breath_pipe_len, d = variants_pipe_plug_out_d);
        translate([0, 0, - eps/2])cylinder(h = variants_breath_pipe_len - 2, d = variants_pipe_plug_out_d - 2);
    }
    cutting_block(thickness = cutting_block_w);
}
