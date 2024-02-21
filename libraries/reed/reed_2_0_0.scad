include <reed.scad>

completeness_percent = 25;

module reed2_base(total_length, end_length, d){
    wall_thickness = 0.11 * d;
    difference() {
        reed_base(total_length, end_length, d);
        translate([0, 0, end_length-0.1]) cylinder(h = total_length, d = d - wall_thickness * 2);
    }
    difference() {
        rotate([0,0,180-(completeness_percent)/2*360/100]) translate([0,0,end_length]) partial_pipe(total_length/10, d+0.8, 0.41, completeness_percent=completeness_percent);
        rotate([0,0,180-(completeness_percent-10)/2*360/100]) translate([0,0,end_length]) translate([0,0,-0.005]) partial_pipe(total_length/10+0.01, d+0.81, 0.41, completeness_percent=completeness_percent-10);
    }
}

module reed2_leaf_socket(heigth_cut_prcnt, d, total_length) {
    // deepens the cut, for more secure leaf hold
    translate([-heigth_cut_prcnt/120 * d, 0, 0]) cube(size=[heigth_cut_prcnt/50 * d * 1.1, d*1.1, total_length * 0.1]);
}

module reed2_base_flat_cutting_cube(d, heigth_cut_prcnt, total_length) {
    translate([d/2 - d * heigth_cut_prcnt / 100-0.001, -d/2, 0.25 * total_length]) {
        cube(size=[heigth_cut_prcnt/100 * d * 1.1, d, total_length * 0.80]);
        reed2_leaf_socket(heigth_cut_prcnt, d, total_length);
    }
}

module reed2_base_flat_cut(total_length, end_length, d, heigth_cut_prcnt) {
    difference(){
        reed2_base(total_length, end_length, d);
        reed2_base_flat_cutting_cube(d, heigth_cut_prcnt, total_length);
    }
}

module reed2_cut(total_length, d, heigth_cut_prcnt, leaf_degree) {
    translate([d/2 - d * heigth_cut_prcnt / 100 + 0.1, -d/2, 0.35 * total_length]) {
        rotate([0, -leaf_degree, 0]) rotate([180, 90, -90]) {
            rotate_extrude(angle = leaf_degree, $fn=100) {
                rotate([0, 0, 90]) {
                    square([d, total_length * 0.70]);
                }
            }
        }
    }
}

module reed2_end_cap(total_length, end_length, d, heigth_cut_prcnt, leaf_degree){
    // filling
    wall_thickness = 0.11 * d;
    avg_r = d/2-wall_thickness;
    difference() {
        translate([0,0,total_length*0.9]) cylinder(h=total_length/10, r=avg_r*1.01);
        union(){
            reed2_cut(total_length, d, heigth_cut_prcnt, leaf_degree);
            reed2_base_flat_cutting_cube(d, heigth_cut_prcnt, total_length);
        }
    }
}

module reed2_leaf(total_length, end_length, d, heigth_cut_prcnt) {
    wall_thickness = d * 0.11;
    leaf_len = (total_length - end_length)*0.9;
    
    // trunk of the leaf ;)
    scale([1,1.25,1]) intersection(){
        cylinder(h=total_length * 0.94, d=d);
        reed2_base_flat_cutting_cube(d, heigth_cut_prcnt, total_length);
    }

    // support stem
    translate([d/2, 0, end_length]) rotate([0,0,-120]) cylinder(leaf_len, leaf_len*0.05, leaf_len*0.01, $fn=3);
    
    // // additional stem to prevent from imploding of leaf
    // translate([d*(1/2 - heigth_cut_prcnt / 54.545), -d/2*1.2, 0.25 * total_length + d/4]) cube([1, d*1.2, 2]);

    // text
    // translate([d/2-wall_thickness/6, d/8, end_length]) rotate([180,-90,0]) reed2_text(total_length, end_length, d, heigth_cut_prcnt, "-", wall_thickness);
    
    // round clip
    difference() {
        rotate([0,0,180-(70)/2*360/100]) translate([0,0,end_length]) partial_pipe(total_length/10, d+0.8, 0.4, completeness_percent=70);
        rotate([0,0,180-(completeness_percent)/2*360/100]) translate([0,0,end_length]) translate([0,0,-0.05]) partial_pipe(total_length/10+0.1, d+0.81, 0.41, completeness_percent=completeness_percent);
    }
}

module reed2_text(total_length, end_length, d, heigth_cut_prcnt, leaf_degree, wall_thickness) {
    my_text = str("L", total_length, " EL", end_length, " D", d, " HC", heigth_cut_prcnt, " LD", leaf_degree);
    linear_extrude(wall_thickness/4) text(my_text, size = (total_length - end_length)/24);
}

module reed2(total_length, end_length, d, heigth_cut_prcnt, leaf_degree) {
    halved_leaf_degree = leaf_degree/2;
    wall_thickness = d * 0.11;
    difference() {
        reed2_base_flat_cut(total_length, end_length, d, heigth_cut_prcnt); // just a flat cut
        reed2_cut(total_length, d, heigth_cut_prcnt, halved_leaf_degree); // deeper cut, half of the leaf degree is added here
    }
    reed2_end_cap(total_length, end_length, d, heigth_cut_prcnt, halved_leaf_degree);
}

