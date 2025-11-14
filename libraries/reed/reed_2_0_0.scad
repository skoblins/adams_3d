completeness_percent = 25;
reed_plug_overhang_suppressor_len = 2;
eps = 0.01;

module reed_plug(end_length, entry_d_in, main_d) {
    entry_d_out = entry_d_in + 1; // minimal wall thickness at the entry
    main_d_out = main_d + variants_reed_pipe_wall_thickness * 2 + variants_reed_pipe_entry_end_out_extra_diameter;

    translate([0, 0, -end_length]){
        difference() {
            cylinder(h = end_length, d1 = entry_d_out, d2 = main_d_out);
            translate([0, 0, -eps / 2]) cylinder(h = end_length + eps, d1 = entry_d_in, d2 = main_d);
        }
    }
}

module reed_plug_equal(total_length, end_length, d) {
    d_out = d + variants_reed_pipe_wall_thickness * 2;

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
    d_out = d+variants_reed_pipe_wall_thickness*2;
    translate([0, 0, end_length]) {
        difference() {
            cylinder(h=total_length - end_length, d=d_out);
            translate([0, 0, -0.1]) cylinder(h = (total_length - end_length) *0.9, d = d);
        }
    } 
}

module reed2_leaf_socket(heigth_cut_prcnt, d, total_length) {
    d_out = d+variants_reed_pipe_wall_thickness*2;
    // deepens the cut, for more secure leaf hold
    translate([-heigth_cut_prcnt/120 * d_out, 0, 0]) cube(size=[heigth_cut_prcnt/50 * d_out * 1.1, d_out*1.1, total_length * 0.1]);
}

module reed2_base_flat_cutting_cube(d, heigth_cut_prcnt, total_length) {
    d_out = d+variants_reed_pipe_wall_thickness*2;
    translate([d_out/2 - d_out * heigth_cut_prcnt / 100, -d_out/2, variants_reed_pipe_end_length]) {
        cube(size=[d_out, d_out, total_length]);
        // reed2_leaf_socket(heigth_cut_prcnt, d, total_length);
    }
}

module reed2_refill_the_cut(total_length, d, heigth_cut_prcnt) {
    d_out = d+variants_reed_pipe_wall_thickness*2;
    x0 = d_out/2 - d_out * heigth_cut_prcnt / 100;
    xs = sin(heigth_cut_prcnt*180/100) * d - variants_reed_pipe_cut_compensation;
    ys = total_length * 0.375;

    // lower refill
    points = [
        [xs, ys],
        [xs, 0],
        [-xs, 0],
        [-xs, ys],
    ];

    echo(variants_reed_pipe_end_length=variants_reed_pipe_end_length);
    translate([x0, 0, variants_reed_pipe_end_length - 0.4]) rotate([90,0,90]) {
        linear_extrude(height=variants_reed_pipe_cut_compensation) {
            // translate([0,variants_reed_pipe_end_length,0]) {
                polygon(points = points);
            // }
        }
    }

    // upper refill
    // ys2 = total_length * 0.1;

    // points2 = [
    //     [xs, ys2],
    //     [xs, 0],
    //     [-xs, 0],
    //     [-xs, ys2],
    //     // [0, total_length * 0.11],
    //     // [xs, total_length * 0.3]
    // ];
    // translate([x0 - sin(variants_reed_pipe_leaf_degree / 100 * 90)*(total_length * 0.9 - variants_reed_pipe_end_length) + 0.5, 0, total_length*0.956]) rotate([90,0,90]) {
    //     linear_extrude(height=0.8) {
    //         // translate([0,variants_reed_pipe_end_length,0]) {
    //             polygon(points = points2);
    //         // }
    //     }
    // }
}

module reed2_base_flat_cut(total_length, end_length, d, heigth_cut_prcnt) {
    difference(){
        reed2_base(total_length, end_length, d);
        translate([variants_reed_pipe_cut_compensation,0, -end_length+eps]) reed2_base_flat_cutting_cube(d, heigth_cut_prcnt, total_length);
    }
}

module reed2_cut(total_length, d, heigth_cut_prcnt, leaf_degree) {
    d_out = d+2*variants_reed_pipe_wall_thickness;
    translate([d_out/2 - d_out * heigth_cut_prcnt / 100 + variants_reed_pipe_cut_compensation + 0.1/*<- fill the little gap between leaf and reed*/, -d_out/2, 0.35 * total_length]) {
        rotate([0, -leaf_degree, 0]) rotate([180, 90, -90]) {
            rotate_extrude(angle = leaf_degree, $fn=100) {
                rotate([0, 0, 90]) {
                    square([d_out, total_length]);
                }
            }
        }
    }
}

module reed2_cut2(total_length, d, heigth_cut_prcnt, leaf_degree_init, leaf_degree_finish = 0) {
    d_out = d+2*variants_reed_pipe_wall_thickness;
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
    d_out = d+2*variants_reed_pipe_wall_thickness;
    leaf_len = (total_length - end_length)*0.9;
    
    // trunk of the leaf ;)
    translate([-d*0.15,0,0]) intersection(){
        cylinder(h=total_length * 0.94, d=d_out*1.25);
        reed2_base_flat_cutting_cube(d_out, heigth_cut_prcnt, total_length);
    }

    // support stem
    translate([d_out/2+leaf_len*stem_heigth_coeff_init/2-d*0.1/2, 0, end_length]) rotate([0,-atan(stem_heigth_coeff_init-stem_heigth_coeff),0]) rotate([0,0,-120]) cylinder(leaf_len, leaf_len*stem_heigth_coeff_init, leaf_len*stem_heigth_coeff, $fn=3);
    
    // text
    // translate([d/2-variants_reed_pipe_wall_thickness/6, d/8, end_length]) rotate([180,-90,0]) reed2_text(total_length, end_length, d, heigth_cut_prcnt, "-", variants_reed_pipe_wall_thickness);
    
    // // round clip
    // difference() {
    //     rotate([0,0,180-(90)/2*360/100]) translate([0,0,end_length]) partial_pipe(total_length/10, d_out+0.8, 0.6, completeness_percent=90);
    //     rotate([0,0,180-(completeness_percent)/2*360/100]) translate([0,0,end_length]) translate([0,0,-0.05]) partial_pipe(total_length/10+0.1, d_out+0.81, 0.61, completeness_percent=completeness_percent);
    // }
}

module reed21_leaf(total_length, end_length, d, heigth_cut_prcnt, stem_heigth_coeff_init, stem_heigth_coeff) {
    d_out = d + 2 * variants_reed_pipe_wall_thickness;
    leaf_len = (total_length - end_length) * 0.94;

    // trunk of the leaf ;)
    intersection(){
        translate([-d_out * variants_leaf_enforcement_thickness_ratio, 0, end_length]) rotate([0, -variants_leaf_enforcement_decrease_ratio, 0]) cylinder(h = leaf_len, d = d_out * 1.25);
        reed2_base_flat_cutting_cube(d_out, heigth_cut_prcnt, total_length);
    }

    w_trunk = cos(heigth_cut_prcnt/100 * 360) * d_out;
    translate([d_out * (1/2 - heigth_cut_prcnt / 100) + variants_leaf_thickness, -w_trunk / 2, end_length]) cube([variants_leaf_thickness + 0.001, w_trunk, leaf_len]);

    // text
    // #translate([d/2-variants_reed_pipe_wall_thickness/6, d/8, end_length]) rotate([180,-90,0]) reed2_text(total_length, end_length, d, heigth_cut_prcnt, "-", variants_reed_pipe_wall_thickness);
}

module leaf21_text(l, w, leaf_enforcement_square_coeff, leaf_enforcement_linear_coeff, leaf_enforcement_const_coeff, leaf_enforcement_support_stem_height) {
    my_text = str("L", l, " W", w, "HC", variants_reed_pipe_cut_prcnt);
    my_text2 = str("A", leaf_enforcement_square_coeff, "B", leaf_enforcement_linear_coeff, "C", leaf_enforcement_const_coeff, "SH", leaf_enforcement_support_stem_height);
    linear_extrude(0.26) {
        text(my_text, size = w / 5, font="Arial:style=Bold");
        translate([0, -w/4, 0]) text(my_text2, size = w/5, font="Arial:style=Bold");
    }
}

module leaf21(l = variants_reed_pipe_length, leaf_enforcement_square_coeff, leaf_enforcement_linear_coeff, leaf_enforcement_const_coeff, leaf_enforcement_support_stem_height) {
    d_out = variants_reed_pipe_in_diameter + 2 * variants_reed_pipe_wall_thickness;
    step_size = 1;
    length = l - variants_reed_pipe_end_length;
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
        // // text
        // translate([0.125, l_width/2, 0.4]) rotate([0, -90, 0]) leaf21_text(length, l_width, leaf_enforcement_square_coeff,
        //     leaf_enforcement_linear_coeff, leaf_enforcement_const_coeff, leaf_enforcement_support_stem_height);
    }
}

module reed2_text1(total_length, end_length, d, heigth_cut_prcnt, leaf_degree, variants_reed_pipe_wall_thickness) {
    my_text = str(total_length, " ", end_length);
    linear_extrude(variants_reed_pipe_wall_thickness * 1.3) text(my_text, size = d/2.5);
}
module reed2_text2(total_length, end_length, d, heigth_cut_prcnt, leaf_degree, variants_reed_pipe_wall_thickness) {
    my_text = str(heigth_cut_prcnt, " ", leaf_degree);
    linear_extrude(variants_reed_pipe_wall_thickness * 1.3) text(my_text, size = d/2.5);
}

module reed2(total_length, end_length, entry_d, main_d, heigth_cut_prcnt, leaf_degree) {
    halved_leaf_degree = leaf_degree/2;
    d_out = entry_d+2*variants_reed_pipe_wall_thickness;

    // first part: plug
    translate([0,0,end_length]) reed_plug(end_length, entry_d, main_d);
    // translate([0,0,end_length]) reed_plug_equal(total_length, end_length, d);

    // main part
    difference() {
        reed2_base_flat_cut(total_length, end_length, main_d, heigth_cut_prcnt); // just a flat cut
        reed2_cut(total_length, main_d, heigth_cut_prcnt, halved_leaf_degree); // deeper cut
    }

    // Text
    translate([-main_d / 2, -(total_length - end_length)/12/2, 1 + end_length + reed_plug_overhang_suppressor_len + total_length/10])
        rotate([0, -90, 0]) reed2_text1(total_length, end_length, main_d, heigth_cut_prcnt, leaf_degree, variants_reed_pipe_wall_thickness);

    rotate([0, 0, 55])
        translate([-main_d / 2, -(total_length - end_length)/12/2, 1 + end_length + reed_plug_overhang_suppressor_len + total_length/10])
            rotate([0, -90, 0]) reed2_text2(total_length, end_length, main_d, heigth_cut_prcnt, leaf_degree, variants_reed_pipe_wall_thickness);

}

