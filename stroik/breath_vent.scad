include <variants-pipe.scad>
include <reed/basic_shapes.scad>
include <reed/tools.scad>

$fn = 100;

vent_thickness = 5;
odlewac_len = 40;
// mod for my old pipe!
//variants_pipe_plug_out_d = 15;
old_pipe_plug_in_d = 7.5;
old_pipe_plug_out_d = 9.5;
plug_to_old_mouth_pipe_len = 12.5;

cutting_block_w = variants_pipe_plug_out_d + 2;
cutting_block_len = variants_breath_pipe_len;

cutting_angle = 11; // [deg]
cutting_depth = cutting_block_w * 0.47;

eps = 0.1;

module cutting_block(thickness = 1, pos_offset = 0) {
    rotate([0, -cutting_angle, 0]) translate([cutting_depth + pos_offset, -cutting_block_w / 2, 0]) cube([thickness, cutting_block_w, cutting_block_len]);
}

//module odlewac_inside() {
    //odlewac_cutting_depth = cutting_block_len * sin(cutting_angle);
//    translate([0, -cutting_block_w / 2, variants_breath_pipe_len]) difference() {
 //       cylinder(h = 30, d = variants_pipe_plug_out_d - vent_thickness);
  //      cube([cutting_block_w / 2, cutting_block_w, 30]);
   // }
//}

module vent_outside_shape() {
    cylinder(h = variants_breath_pipe_len + odlewac_len, d = variants_pipe_plug_out_d);
}

module vent_inside_shape(extrusion = 0) {
    translate([0, 0, - eps/2]) cylinder(h = variants_breath_pipe_len - 2, d = variants_pipe_plug_out_d + extrusion);
    translate([0, 0, variants_breath_pipe_len - eps/2])
    intersection() {
        #translate([0, 0, -3.1]) cylinder(h = odlewac_len, d = variants_pipe_plug_out_d + extrusion);
        union() {
            #translate([-variants_pipe_plug_out_d /4 - 2, 0, odlewac_len / 2 - 3]) cube([variants_pipe_plug_out_d /2, variants_pipe_plug_out_d, odlewac_len], true);
            translate([2, 0, odlewac_len / 2 + 4]) cube([variants_pipe_plug_out_d /2, variants_pipe_plug_out_d, odlewac_len], true);
        }
    }

}

module  breath_vent(){
    difference() {
        difference() {
            vent_outside_shape();
            vent_inside_shape(extrusion = -vent_thickness);
        }
        cutting_block(thickness = variants_breath_pipe_len, pos_offset = 1);
    }

    intersection() {
        intersection() {
            cutting_block();
            vent_inside_shape();
        }
        for(z = [30 : 8 : 90]) {
            translate([-10, -10, z]) cube([20 , 20, 1]);
        }
    }
}

//module breath_vent_flap() {
//    color("orange")
//    intersection() {
//        vent_outside_shape();
//        cutting_block(thickness = 1);
//    }
//}

module plug_to_old_mouth_pipe() {
    base_pipe_b(l = plug_to_old_mouth_pipe_len + eps, d_in = old_pipe_plug_in_d, d_out = old_pipe_plug_out_d);
}

module connection_between_2_diameters() {
    base_pipe_b(l = 2 + eps, d_in = old_pipe_plug_in_d, d_out = variants_pipe_plug_out_d);
}

stack(heights = [plug_to_old_mouth_pipe_len, plug_to_old_mouth_pipe_len + 1, plug_to_old_mouth_pipe_len + 1 + variants_breath_pipe_len]) {
    plug_to_old_mouth_pipe();
    connection_between_2_diameters();
    breath_vent();
}

%translate([10, 0, plug_to_old_mouth_pipe_len + 1]) breath_vent_flap();

