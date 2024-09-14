include <constructive/constructive-compiled.scad>

$fn = 100;
clearance = 1;
//grip_clearance = 2;

eps = 0.2;
shaft_d = 5;
main_shaft_middle_part_out_d = 2* shaft_d;
gripper_wall = 3;
shaft_travel_l = 4;
shaft_h = 40;
base_d = 2.5 * shaft_d;
latch_l = 40;
latch_r = 40;
latch_w = shaft_h/4 - clearance;
latch_base_sides_d_in = shaft_d;
latch_base_sides_d_out = shaft_d * 1.5;
latch_thickness = latch_base_sides_d_out - latch_base_sides_d_in;

module main_shaft_middle_part() {
    cylinder(h = shaft_h/2, d = main_shaft_middle_part_out_d, center = true);
}

module main_shaft_middle_part_with_latch_rod() {
    main_shaft_middle_part();
    Y(base_d/8) turnXY(70) X(-latch_l + latch_thickness/2) Z(-latch_w) rotate_extrude(angle=latch_r) X(latch_l) square([latch_thickness, latch_w * 2]);
}

module main_shaft() {
    X(shaft_travel_l/2) two() reflectZ(sides(1)) Z(shaft_h*3/8 - eps/2) {
        difference() {
            union() {
                cylinder(h = shaft_h/4 + eps, d = shaft_d - eps, center = true);
                Z(shaft_h/7.25) cylinder(h =1, d = 1.1 * shaft_d, center = true);
            }
            cut_w = shaft_d/3;
            Z(shaft_d/2 + eps) Y(-cut_w/2) X(-shaft_d) cube(size=[2*shaft_d,cut_w,shaft_d], center=false);
        }
    }
    main_shaft_middle_part();
}

module hole_cutter_for_the_rod(center_shift = 0) {
    X(center_shift) cylinder(h = shaft_h + eps, d = shaft_d, center = true);
}

module main_shaft_with_latch_rod() {
    X(shaft_travel_l/2) two() reflectZ(sides(1)) Z(shaft_h*3/8 - eps/2) {
        difference() {
            union() {
                cylinder(h = shaft_h/4 + eps, d = shaft_d - eps, center = true);
                Z(shaft_h/7.25) cylinder(h =1, d = 1.1 * shaft_d, center = true);
            }
            cut_w = shaft_d/3;
            Z(shaft_d/2 + eps) Y(-cut_w/2) X(-shaft_d) cube(size=[2*shaft_d,cut_w,shaft_d], center=false);
        }
    }
    difference() {
        main_shaft_middle_part_with_latch_rod();
        union() {
            //hole_cutter_for_the_rod();
            cylinder(h = shaft_h/4 + eps, d = base_d + eps, center = true);
        }
    }
}

module latch_grip() {
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

module latch_rods() {
    X(shaft_travel_l/2) two() Z(sides(shaft_h*3/8)) latch_grip();
}

module base() {
    difference() {
        cylinder(h = shaft_h/4 - eps, d = base_d - eps, center = true);
        hole_cutter_for_the_rod();
    }
}


assemble() {
    add() {
        main_shaft();
        Y(-50) latch_rods();
        Y(50) base();
        Y(100) main_shaft_with_latch_rod();
    }
}
