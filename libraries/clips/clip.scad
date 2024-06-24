include <constructive/constructive-compiled.scad>

$fn = 50;
clearance = 1;
grip_clearance = 2;

eps = 0.1;
shaft_d = 5;
main_shaft_middle_part_out_d = 2* shaft_d;
gripper_wall = 3;
shaft_travel_l = 3;
shaft_h = 40;
base_d = 2.1 * shaft_d;

module main_shaft_middle_part() {
    cylinder(h = shaft_h/2, d = main_shaft_middle_part_out_d, center = true);
}

module main_shaft() {
    X(shaft_travel_l/2) two() Z(sides(shaft_h*3/8 - eps/2)) cylinder(h = shaft_h/4 + eps, d = shaft_d, center = true);
    main_shaft_middle_part();
}

module main_shaft_grip() {
    X(shaft_travel_l/2) {
        two() Z(sides(shaft_h*3/8)) tube(h=shaft_h/4-clearance,dInner=shaft_d+clearance,dOuter=shaft_d * 1.5);
    }
}

module base() {
    difference() {
        cylinder(h = shaft_h/2 * 1.1, d = base_d*1.3, center = true);
        union() {
            X(-main_shaft_middle_part_out_d/3) scale(1.01) cylinder(h = shaft_h/2, d = main_shaft_middle_part_out_d + clearance, center = true);
            X(-main_shaft_middle_part_out_d/3)cylinder(h = shaft_h/2 * 1.2, d = main_shaft_middle_part_out_d, center = true);
        }
    }
}


assemble() {
    add() {
        clear(gray) main_shaft();
        %clear(brown) main_shaft_grip();
        Y(-2*main_shaft_middle_part_out_d) clear("white") base();
    }
}
