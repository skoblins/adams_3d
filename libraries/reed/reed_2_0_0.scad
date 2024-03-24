include <reed.scad>

completeness_percent = 25;
wall_thickness = 0.8;
reed_plug_overhang_suppressor_len = 2;
eps = 0.01;

module reed_plug(total_length, end_length, d) {
    d_out = d + wall_thickness * 2;

    translate([0, 0, -end_length]){
        difference() {
            cylinder(h = end_length, d2 = d_out * 1.1, d1 = d + 0.8);
            translate([0, 0, -eps / 2]) cylinder(h = end_length + eps, d = d);
        }
    }

    // // anti overhanger
    // translate([0,0,0]) {
    //     difference() {
    //         cylinder(h=reed_plug_overhang_suppressor_len,d1=d_out*1.1,d2=d+0.8);
    //         translate([0,0,-eps/2]) cylinder(h=2+eps,d=d);
    //     }
    // }
}

module reed_plug_equal(total_length, end_length, d) {
    d_out = d + wall_thickness * 2;

    translate([0, 0, -end_length]){
        difference() {
            cylinder(h = end_length, d = d_out);
            translate([0, 0, -eps / 2]) cylinder(h = end_length + eps, d = d);
        }
    }

    // // anti overhanger
    // translate([0,0,0]) {
    //     difference() {
    //         cylinder(h=reed_plug_overhang_suppressor_len,d1=d_out*1.1,d2=d+0.8);
    //         translate([0,0,-eps/2]) cylinder(h=2+eps,d=d);
    //     }
    // }
}

module reed2_base(total_length, end_length, d){
    d_out = d+wall_thickness*2;
    translate([0, 0, end_length]) {
        difference() {
            cylinder(h=total_length - end_length, d=d_out);
            translate([0, 0, -0.1]) cylinder(h = (total_length - end_length)*0.9, d = d);
        }
    } 
}

module reed2_leaf_socket(heigth_cut_prcnt, d, total_length) {
    d_out = d+wall_thickness*2;
    // deepens the cut, for more secure leaf hold
    translate([-heigth_cut_prcnt/120 * d_out, 0, 0]) cube(size=[heigth_cut_prcnt/50 * d_out * 1.1, d_out*1.1, total_length * 0.1]);
}

module reed2_base_flat_cutting_cube(d, heigth_cut_prcnt, total_length) {
    d_out = d+wall_thickness*2;
    translate([d_out/2 - d_out * heigth_cut_prcnt / 100, -d_out/2, variants_reed_pipe_end_length]) {
        cube(size=[d_out, d_out, total_length]);
        // reed2_leaf_socket(heigth_cut_prcnt, d, total_length);
    }
}

module reed2_refill_the_cut(total_length, d, heigth_cut_prcnt) {
    d_out = d+wall_thickness*2;
    x0 = d_out/2 - d_out * heigth_cut_prcnt / 100 - 0.4;

    points = [
        [sin(heigth_cut_prcnt*180/100) * d_out, total_length * 0.2],
        [sin(heigth_cut_prcnt*180/100) * d_out, total_length * 0],
        [-sin(heigth_cut_prcnt*180/100) * d_out, total_length * 0],
        [-sin(heigth_cut_prcnt*180/100) * d_out, total_length * 0.2],
        [0, total_length * 0.11],
        [sin(heigth_cut_prcnt*180/100) * d_out, total_length * 0.2]
    ];

    echo(variants_reed_pipe_end_length=variants_reed_pipe_end_length);
    translate([x0, 0, variants_reed_pipe_end_length - 0.4]) rotate([90,0,90]) {
        linear_extrude(height=0.6) {
            // translate([0,variants_reed_pipe_end_length,0]) {
                polygon(points = points);
            // }
        }
    }
}

module reed2_base_flat_cut(total_length, end_length, d, heigth_cut_prcnt) {
    difference(){
        union() {
            reed2_base(total_length, end_length, d);
            reed2_refill_the_cut(total_length, d, heigth_cut_prcnt);
        }
        translate([0,0, -4.25 ]) reed2_base_flat_cutting_cube(d, heigth_cut_prcnt, total_length+2/*a gap for reed fitting*/);
    }
}

module reed2_cut(total_length, d, heigth_cut_prcnt, leaf_degree) {
    d_out = d+2*wall_thickness;
    translate([d_out/2 - d_out * heigth_cut_prcnt / 100 + 0.1/*<- fill the little gap between leaf and reed*/, -d_out/2, 0.35 * total_length]) {
        rotate([0, -leaf_degree, 0]) rotate([180, 90, -90]) {
            rotate_extrude(angle = leaf_degree, $fn=100) {
                rotate([0, 0, 90]) {
                    square([d_out, total_length * 0.70]);
                }
            }
        }
    }
}

module reed2_cut2(total_length, d, heigth_cut_prcnt, leaf_degree_init, leaf_degree_finish = 0) {
    d_out = d+2*wall_thickness;
    translate([d_out/2 - d_out * heigth_cut_prcnt / 100 + 0.1/*<- fill the little gap between leaf and reed*/, -d_out/2, 0.35 * total_length]) {
        rotate([0, -leaf_degree_init, 0]) rotate([180, 90, -90]) {
            rotate_extrude(angle = leaf_degree_init, $fn=100) {
                rotate([0, 0, 90]) {
                    square([d_out, total_length * 0.70]);
                }
            }
        }
    }
}

module reed2_leaf(total_length, end_length, d, heigth_cut_prcnt, stem_heigth_coeff_init, stem_heigth_coeff) {
    d_out = d+2*wall_thickness;
    leaf_len = (total_length - end_length)*0.9;
    
    // trunk of the leaf ;)
    translate([-d*0.15,0,0]) intersection(){
        cylinder(h=total_length * 0.94, d=d_out*1.25);
        reed2_base_flat_cutting_cube(d_out, heigth_cut_prcnt, total_length);
    }

    // support stem
    translate([d_out/2+leaf_len*stem_heigth_coeff_init/2-d*0.1/2, 0, end_length]) rotate([0,-atan(stem_heigth_coeff_init-stem_heigth_coeff),0]) rotate([0,0,-120]) cylinder(leaf_len, leaf_len*stem_heigth_coeff_init, leaf_len*stem_heigth_coeff, $fn=3);
    
    // text
    // translate([d/2-wall_thickness/6, d/8, end_length]) rotate([180,-90,0]) reed2_text(total_length, end_length, d, heigth_cut_prcnt, "-", wall_thickness);
    
    // // round clip
    // difference() {
    //     rotate([0,0,180-(90)/2*360/100]) translate([0,0,end_length]) partial_pipe(total_length/10, d_out+0.8, 0.6, completeness_percent=90);
    //     rotate([0,0,180-(completeness_percent)/2*360/100]) translate([0,0,end_length]) translate([0,0,-0.05]) partial_pipe(total_length/10+0.1, d_out+0.81, 0.61, completeness_percent=completeness_percent);
    // }
}

module reed21_leaf(total_length, end_length, d, heigth_cut_prcnt, stem_heigth_coeff_init, stem_heigth_coeff) {
    d_out = d + 2 * wall_thickness;
    leaf_len = (total_length - end_length) * 0.94;

    // trunk of the leaf ;)
    intersection(){
        translate([-d_out * variants_leaf_enforcement_thickness_ratio, 0, end_length]) rotate([0, -variants_leaf_enforcement_decrease_ratio, 0]) cylinder(h = leaf_len, d = d_out * 1.25);
        reed2_base_flat_cutting_cube(d_out, heigth_cut_prcnt, total_length);
    }

    w_trunk = cos(heigth_cut_prcnt/100 * 360) * d_out;
    translate([d_out * (1/2 - heigth_cut_prcnt / 100) + variants_leaf_thickness, -w_trunk / 2, end_length]) cube([variants_leaf_thickness + 0.001, w_trunk, leaf_len]);

    // text
    // #translate([d/2-wall_thickness/6, d/8, end_length]) rotate([180,-90,0]) reed2_text(total_length, end_length, d, heigth_cut_prcnt, "-", wall_thickness);
}

module leaf21_text(l, w) {
    my_text = str("L", l, " W", w, "HC", variants_reed_pipe_cut_prcnt);
    my_text2 = str("A", variants_leaf_enforcement_square_coeff, "B", variants_leaf_enforcement_linear_coeff, "C", variants_leaf_enforcement_const_coeff);
    linear_extrude(0.26) {
        text(my_text, size = l/12, font="Arial:style=Bold");
        translate([0, -l/11, 0]) text(my_text2, size = l/12, font="Arial:style=Bold");
    }
}

module leaf21(leaf_enforcement_square_coeff, leaf_enforcement_linear_coeff, leaf_enforcement_const_coeff, leaf_enforcement_support_stem_height) {
    d_out = variants_reed_pipe_in_diameter + 4 * variants_reed_pipe_wall_thickness;
    step_size = 1;
    length = (variants_reed_pipe_length - variants_reed_pipe_end_length) * 0.96;
    l_width = d_out;/*sin(variants_reed_pipe_cut_prcnt / 100 * 180) * d_out * 2.5*/;


    function thickness(z) = leaf_enforcement_square_coeff * pow(length - z, 2) + leaf_enforcement_linear_coeff * (length - z) + leaf_enforcement_const_coeff;

    difference() {
        union() {
            intersection() {
                translate([-sin((variants_reed_pipe_cut_prcnt) / 100 * 180) * l_width, l_width / 2, 0]) cylinder(h = length, d = l_width);
                union() {
                    for(z = [0 : step_size : length]) {
                        hull() {
                            translate([0, 0, z]) cube([thickness(z), l_width, 1]);
                            translate([0, 0, z - step_size]) cube([thickness(z - step_size), l_width, 1]);
                        }
                        echo(z, l_width, thickness(z));
                    }
                    hull() {
                        translate([0, 0, length]) cube([thickness(length), l_width, 1]);
                        translate([0, 0, length - step_size]) cube([thickness(length - step_size), l_width, 1]);
                    }
                }
            }
            translate([eps, d_out/2, 0]) cube([leaf_enforcement_support_stem_height, 0.4, length]);
        }
        // text
        translate([0.125, l_width/2, 0.4]) rotate([0, -90, 0]) leaf21_text(l = length, w = l_width);
    }
}

module reed2_text1(total_length, end_length, d, heigth_cut_prcnt, leaf_degree, wall_thickness) {
    my_text = str("L", total_length, " EL", end_length, " D", d);
    linear_extrude(wall_thickness * 1.3) text(my_text, size = (total_length - end_length)/12);
}
module reed2_text2(total_length, end_length, d, heigth_cut_prcnt, leaf_degree, wall_thickness) {
    my_text = str(" HC", heigth_cut_prcnt, " LD", leaf_degree);
    linear_extrude(wall_thickness * 1.3) text(my_text, size = (total_length - end_length)/12);
}

module reed2(total_length, end_length, d, heigth_cut_prcnt, leaf_degree) {
    halved_leaf_degree = leaf_degree/2;
    d_out = d+2*wall_thickness;

    // first part: plug
    // translate([0,0,end_length]) reed_plug(total_length, end_length, d);
    translate([0,0,end_length]) reed_plug_equal(total_length, end_length, d);

    // main part
    difference() {
        reed2_base_flat_cut(total_length, end_length, d, heigth_cut_prcnt); // just a flat cut
        reed2_cut(total_length, d, heigth_cut_prcnt, halved_leaf_degree); // deeper cut, half of the leaf degree is added here
    }

    // // grips

    //     // vertical grip
    //     difference() {
    //         rotate([0,0,180-(completeness_percent)/2*360/100]) translate([0,0,end_length+reed_plug_overhang_suppressor_len]) partial_pipe(total_length/10, d_out+0.8, 0.41, completeness_percent=completeness_percent);
    //         rotate([0,0,180-(completeness_percent-10)/2*360/100]) translate([0,0,end_length+reed_plug_overhang_suppressor_len]) translate([0,0,-0.005]) partial_pipe(total_length/10+0.01, d_out+0.81, 0.41, completeness_percent=completeness_percent-10);
    //     }

        // horizontal grip - powstrzymuje klej!!!
        difference() {
            translate([0,0,end_length+reed_plug_overhang_suppressor_len+total_length/10]) {
                difference() {
                    cylinder(h=reed_plug_overhang_suppressor_len,d1=d_out*1.2,d2=d);
                    translate([0,0,-eps/2]) cylinder(h=2+eps,d=d);
                }
            }
            reed2_base_flat_cutting_cube(d, variants_reed_pipe_cut_prcnt, total_length);
        }

    translate([-d / 2, -(total_length - end_length)/12/2, 1 + end_length + reed_plug_overhang_suppressor_len + total_length/10])
        rotate([0, -90, 0]) reed2_text1(total_length, end_length, d, heigth_cut_prcnt, leaf_degree, wall_thickness);

    rotate([0, 0, 45])
        translate([-d / 2, -(total_length - end_length)/12/2, 1 + end_length + reed_plug_overhang_suppressor_len + total_length/10])
            rotate([0, -90, 0]) reed2_text2(total_length, end_length, d, heigth_cut_prcnt, leaf_degree, wall_thickness);

}

