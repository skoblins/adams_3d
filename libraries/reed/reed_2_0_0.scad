include <reed.scad>

completeness_percent = 25;
wall_thickness = 0.8;
reed_plug_overhang_suppressor_len = 2;
eps = 0.01;

module reed_plug(total_length, end_length, d) {
    d_out = d+wall_thickness*2;

    translate([0,0,-end_length]){
        difference() {
            cylinder(h=end_length,d2=d_out*1.2,d1=d);
            translate([0,0,-eps/2]) cylinder(h=end_length+eps,d=d);
        }
    }

    // anti overhanger
    translate([0,0,0]) {
        difference() {
            cylinder(h=reed_plug_overhang_suppressor_len,d1=d_out*1.2,d2=d);
            translate([0,0,-eps/2]) cylinder(h=2+eps,d=d);
        }
    }
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
    translate([d_out/2 - d_out * heigth_cut_prcnt / 100, -d_out/2, 0.25 * total_length]) {
        cube(size=[d_out, d_out, total_length * 0.80]);
        // reed2_leaf_socket(heigth_cut_prcnt, d, total_length);
    }
}

module reed2_base_flat_cut(total_length, end_length, d, heigth_cut_prcnt) {
    difference(){
        reed2_base(total_length, end_length, d);
        translate([0,0,-0.5]) reed2_base_flat_cutting_cube(d, heigth_cut_prcnt, total_length+2/*a gap for reed fitting*/);
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

module reed2_text(total_length, end_length, d, heigth_cut_prcnt, leaf_degree, wall_thickness) {
    my_text = str("L", total_length, " EL", end_length, " D", d, " HC", heigth_cut_prcnt, " LD", leaf_degree);
    linear_extrude(wall_thickness) text(my_text, size = (total_length - end_length)/24);
}

module reed2(total_length, end_length, d, heigth_cut_prcnt, leaf_degree) {
    halved_leaf_degree = leaf_degree/2;
    d_out = d+2*wall_thickness;

    // first part: plug
    translate([0,0,end_length]) reed_plug(total_length, end_length, d);

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
            reed2_base_flat_cutting_cube(d, 11, total_length);
        }
}

