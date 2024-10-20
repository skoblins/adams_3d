include <constructive/constructive-compiled.scad>

$fn = 100;
eps = 0.2;
clearance = 1;
base_pads_angle = 22.5;

module tightening_clip() {
    
    shaft_d = 7;
    main_shaft_middle_part_out_d = 2* shaft_d;
    shaft_travel_l = 4;
    shaft_h = 20;
    base_d = 2.1 * shaft_d;
    latch_l = 40;
    latch_r = 40;
    latch_w = shaft_h/4;
    latch_base_sides_d_in = shaft_d;
    latch_base_sides_d_out = shaft_d * 1.5;
    latch_thickness = latch_base_sides_d_out - latch_base_sides_d_in;

    turnXY(90) main_shaft(base_d, shaft_travel_l, shaft_h, shaft_d, main_shaft_middle_part_out_d);
    X(shaft_travel_l / 2) Y(latch_l / 4) turnXY(180) latch_rods(shaft_travel_l, latch_l, latch_w - clearance, shaft_h, latch_r, latch_base_sides_d_in, latch_base_sides_d_out, latch_thickness);
    Y((latch_l + shaft_travel_l) / 2) turnXY(90 + 180) main_shaft_with_latch_rod(shaft_travel_l, shaft_h, shaft_d, main_shaft_middle_part_out_d, base_d, latch_thickness, latch_l, latch_w, latch_r);
}

module main_shaft_middle_part(base_d, shaft_h, main_shaft_middle_part_out_d) {
    cylinder(h = shaft_h/2, d = main_shaft_middle_part_out_d, center = true);
}

module main_shaft_middle_part_with_latch_rod(base_d, shaft_h, out_d, latch_thickness, latch_l, latch_w, latch_r) {
    main_shaft_middle_part(base_d, shaft_h, out_d);
    Y(base_d/8) turnXY(65) X(-latch_l + latch_thickness/2) Z(-latch_w) rotate_extrude(angle = latch_r) X(latch_l) square([latch_thickness, latch_w * 2]);
}

module main_shaft(base_d, shaft_travel_l, shaft_h, shaft_d, out_d) {
    two() reflectZ(sides(1)) Z(shaft_h*3/8 - eps/2) {
        cylinder(h = shaft_h/4 + eps, d = shaft_d - clearance/2, center = true);
        Z(shaft_h/7.25) cylinder(h =1, d = 1.25 * shaft_d, center = true);
    }
    main_shaft_middle_part(base_d, shaft_h, shaft_d * 1.25);
    turnXY(base_pads_angle) Y(-base_d / 3)box(x = base_d/2, y = base_d/2, z = shaft_h/2 - eps);
}

module hole_cutter_for_the_rod(shaft_h, shaft_d, center_shift) {
    X(center_shift) cylinder(h = shaft_h + eps, d = shaft_d, center = true);
}

module main_shaft_with_latch_rod(shaft_travel_l, shaft_h, shaft_d, out_d, base_d, latch_thickness, latch_l, latch_w, latch_r) {
    X(shaft_travel_l/2) two() reflectZ(sides(1)) Z(shaft_h*3/8 - eps/2) {
        cylinder(h = shaft_h/4 + eps, d = shaft_d - clearance/2, center = true);
        Z(shaft_h/7.25) cylinder(h =1, d = 1.25 * shaft_d, center = true);
    }
    difference() {
        main_shaft_middle_part_with_latch_rod(base_d, shaft_h, out_d, latch_thickness, latch_l, latch_w, latch_r);
        cylinder(h = shaft_h/4 + eps, d = base_d + clearance/2, center = true);
    }
    hole_cutter_for_the_rod(shaft_h / 4, shaft_d - 1, 0);
    base(shaft_h, shaft_d, base_d);
    turnXY(-base_pads_angle + 180) Y(-base_d / 2)box(x = base_d/2, y = base_d/6, z = shaft_h/4 - eps);
}

module latch_grip(latch_l, latch_w, latch_r, latch_base_sides_d_in, latch_base_sides_d_out, latch_thickness) {
    my_latch_l = latch_l/2;
    two() reflectY(sides(1)) Y(-my_latch_l/2) turnXY(-latch_r/1.25) {
        difference() {
            union() {
                tube(h = latch_w, dInner = latch_base_sides_d_in, dOuter = latch_base_sides_d_out);
                X(-my_latch_l + latch_thickness/2) Z(-latch_w/2) rotate_extrude(angle=latch_r) X(my_latch_l) square([latch_thickness, latch_w]);
            }
            tube(h = latch_w, d = latch_base_sides_d_in, solid = true);
        }
    }
}

module latch_rods(shaft_travel_l, latch_l, latch_w, shaft_h, latch_r, latch_base_sides_d_in, latch_base_sides_d_out, latch_thickness) {
    X(shaft_travel_l/2) two() Z(sides(shaft_h*3/8 - eps))
    latch_grip(latch_l, latch_w, latch_r, latch_base_sides_d_in, latch_base_sides_d_out, latch_thickness);
}

module base(shaft_h, shaft_d, base_d) {
    difference() {
        cylinder(h = shaft_h/4 - eps, d = base_d - clearance/2, center = true);
        hole_cutter_for_the_rod(shaft_h, shaft_d, 0);
    }
}

tightening_clip();
