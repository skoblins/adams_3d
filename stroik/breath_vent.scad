include <variants-pipe.scad>
include <reed/basic_shapes.scad>
include <reed/tools.scad>

$fn = 100;

// mod for my old pipe!
variants_pipe_plug_out_d = 17;

cutting_block_w = variants_pipe_plug_out_d + 2;

eps = 0.1;

module cutting_block(thickness = 1, pos_offset = 0) {
    rotate([0, -12, 0]) translate([cutting_block_w/2 + pos_offset, -cutting_block_w / 2, 0]) cube([thickness, cutting_block_w, variants_breath_pipe_len]);
}

module outside_shape() {
    cylinder(h = variants_breath_pipe_len, d = variants_pipe_plug_out_d);
}

module inside_shape(extrusion = 0) {
    translate([0, 0, - eps/2])cylinder(h = variants_breath_pipe_len - 2, d = variants_pipe_plug_out_d + extrusion);
}

module  breath_vent(){
    difference() {
        difference() {
            outside_shape();
            inside_shape(extrusion = -5);
        }
        cutting_block(thickness = variants_breath_pipe_len, pos_offset = 1);
    }

    intersection() {
        intersection() {
            cutting_block();
            inside_shape();
        }
        for(z = [30 : 15 : 90]) {
            translate([-10, -10, z]) cube([20 , 20, 1]);
        }
    }
}

module breath_vent_flap() {
    color("orange") 
    intersection() {
        outside_shape();
        cutting_block(thickness = 1);
    }
}

module plug_to_old_mouth_pipe() {
    base_pipe_b(l = plug_to_old_mouth_pipe_len + eps, d_in = 8.0, d_out = 9.5);
}

module connection_between_2_diameters() {
    base_pipe_b(l = 2 + eps, d_in = 8.5, d_out = variants_pipe_plug_out_d);
}

plug_to_old_mouth_pipe_len = 15;

stack(heights = [plug_to_old_mouth_pipe_len, plug_to_old_mouth_pipe_len + 1, plug_to_old_mouth_pipe_len + 1 + variants_breath_pipe_len]) {
    #plug_to_old_mouth_pipe();
    connection_between_2_diameters();
    breath_vent();
}

%translate([10, 0, plug_to_old_mouth_pipe_len + 1]) breath_vent_flap();

