//use <smooth-prim/smooth_prim.scad>
include <constructive/constructive-compiled.scad>
use <connectors/snap.scad>

$fn = 100;

// paramters
eps = 0.5;

middle_rant_h = 2;
additional_top_thickness = 1;
cutter_z_size = middle_rant_h + additional_top_thickness;

x_in_size = 29 + eps;
y_in_size = 34 + eps;
z_in_size = 10.6 + eps;
thickness_coeff = 1.15; // will determine how thick is the shell, in relation to inside size
rounding = (x_in_size + y_in_size + z_in_size) / 20;
battery_z_offset = -1.5;

x_out_size = x_in_size * thickness_coeff;
y_out_size = y_in_size * thickness_coeff;
z_out_size = z_in_size * thickness_coeff;

opening_gap_z_offset = z_out_size - cutter_z_size - middle_rant_h;

x_diff = x_in_size * (thickness_coeff - 1);
y_diff = y_in_size * (thickness_coeff - 1);
z_diff = z_in_size * (thickness_coeff - 1);

x_offset = -x_diff / 2;
y_offset = -y_diff / 2;
z_offset = -z_diff / 2;

// diode
diode_d = 3.1; //[mm]
diode_x_offset = 18.75;
diode_y_offset = 32.38; //

// buttons common
button_d = 5; //[mm]
button_x_offset = x_in_size - eps/2 - 6.36 - 1.75; // with regards to the center of the button
button_rant_size = 3.5;
side_holder_strip_l = 11;

// button1
button1_y_offset = 27.74 - button_d / 2;//

// button2
button2_y_offset = 16.68 - button_d / 2; //

// hole for keys
hole_in_d = 10;
hole_out_d = 20;

// modules
module inside() {
    TORIGHT() TOUP() TOREAR() {
        difference() {
            chamfer(-1,-1,-1, fnCorner=60) box(x = x_in_size, y = y_in_size, z = z_in_size);
            union() {
                battery_infill_y = 2;
                color("red") box(x = 7, y = battery_infill_y, z = 8);
                color("red") Y(y_in_size - battery_infill_y) box(x = 7, y = battery_infill_y, z = 8);
            }
        }
        // opening gap
        X(x_out_size / 2 - x_in_size / 4 + x_diff / 3) Y(-y_diff * 1.25) Z(opening_gap_z_offset) chamfer(-0.4,-0.4,-0.4, fnCorner=20) box(x = x_in_size / 4, y = y_diff, z = 1);
    }
}

module outside() {
    translate([x_offset, y_offset, z_offset]) TORIGHT() TOUP() TOREAR() chamfer(-2,-2,-2, fnCorner=60) color("gray") box(x = x_out_size, y = y_out_size, z = z_out_size + additional_top_thickness);
}

module button_rants() {
    // button1 rant
    translate([button_x_offset - 1, button1_y_offset - 1, z_in_size - eps/2]) TORIGHT() TOUP() TOREAR() chamfer(-0.5, -0.5, -0.5, fnCorner = 30) color("green") box(x = button_d + 2, y = button_d + 2, z = 2);

    // button2 rant
    translate([button_x_offset - 1, button2_y_offset - 1, z_in_size - eps/2]) TORIGHT() TOUP() TOREAR() chamfer(-0.5, -0.5, -0.5, fnCorner = 30) color("red") box(x = button_d + 2, y = button_d + 2, z = 2);
}

module diode_cutout() {
    translate([diode_x_offset, diode_y_offset, -z_offset + 1]) cylinder(h = z_in_size + 1 + eps/*not too important...*/, d = diode_d + eps);
    // dent
    dent_r = 5;
    X(diode_x_offset + diode_d / 2 - 1.5) Y(diode_y_offset + diode_d / 2 - 1.5) Z(z_in_size + dent_r / 1.9) ball(d = dent_r);
}

module buttons_cutout() {
    dent_r = 15;
    eps = 0.35;
    //button1
    translate([button_x_offset - eps/2, button1_y_offset - eps/2, z_in_size - eps/2]) cube(size=[button_d + eps, button_d + eps, button_d]);
    X(button_x_offset + button_d / 2) Y(button1_y_offset + button_d / 2) Z(z_in_size + dent_r / 1.9) ball(d = dent_r);
    //button2
    translate([button_x_offset - eps/2, button2_y_offset - eps/2, z_in_size - eps/2]) cube(size=[button_d + eps, button_d + eps, button_d]);
    X(button_x_offset + button_d / 2) Y(button2_y_offset + button_d / 2) Z(z_in_size + dent_r / 1.9) ball(d = dent_r);
}

module hole_for_key_ring() {
    chamfer(-2, -2, fnCorner=60) color("gray") tube(d = hole_out_d, h = z_out_size * 0.5, wall = 4);
}

module button() {
    TOUP() TORIGHT() TOREAR() box(x = button_d, y = button_d, z = 4);
    translate([-button_rant_size / 2, -button_rant_size / 2 , -1.5]) {
        cube(size=[button_d + button_rant_size, button_d + button_rant_size, 2.5]);
        Z(2 - 0.6 + eps) {
            turnXY(55) X(button_d * 1.35) Y(-2) cube(size=[button_d /2 , button_d + button_rant_size + side_holder_strip_l, 0.6]);
        }
    }
}

module button_protection() {
    w = 1;
    clearance = 0.75;
    depth = 1.5;
    travel = 1;
    // cube(size=[button_d, button_d, 4]);
    difference() {
        X(-(button_rant_size + w + clearance) / 2) Y((button_d + button_rant_size + w + clearance) / 8) Z(-1.5 + 4 - w - clearance - travel) {
            cube(size=[button_d + button_rant_size + w + clearance, (button_d + button_rant_size + w + clearance) / 4, 11 - eps]);
        }
        X(-(button_rant_size + w + clearance) / 2) Y((button_d + button_rant_size + w + clearance) / 8) Z(-1.5 + 4 - w - clearance - travel) {
            cube(size=[button_d + button_rant_size + w + clearance, (button_d + button_rant_size + w + clearance) / 4, 11 - eps]);
        }
    }
}

module buttons() {
    // loose buttons
    color("green") button();
    X(10) color("red") button();
}

module no_cut_cars_pilot() {
    difference() {
         outside();
         union() {
            inside();
            diode_cutout();
            buttons_cutout();
        }
    }
    translate([x_in_size / 2, y_in_size + hole_out_d / 2, z_offset ]) TOUP() hole_for_key_ring();
}

module box_rant() {
    thickness_c = 1 + (thickness_coeff - 1) / 2;
    difference() {
        box(x = x_out_size + eps, y = y_out_size + eps, z = middle_rant_h + eps);
        Z(-eps / 2) box(x = x_out_size / thickness_c, y = y_out_size / thickness_c, z = middle_rant_h + eps);
    }
}

module pilot_cutter(){
    cutter_x = 2 * x_in_size;
    cutter_y = 2 * y_in_size;

    X(cutter_x / 4) Y(cutter_y / 4) Z(z_out_size - cutter_z_size + eps) TOUP() {
        box(x = cutter_x, y = cutter_y, z = cutter_z_size);
        Z(-middle_rant_h) box_rant();
    }
}

module cars_pilot_upper()
{
    // cut it at the top...
    intersection() {
        pilot_cutter();
        no_cut_cars_pilot();
    }
    // add snaps!
    snap_z = 7;
    snap_l = 20;
    thickness_c = 1 + (thickness_coeff - 1) / 2;
    box_th = (x_out_size - x_in_size) / 2;
    snap_w = (x_out_size - x_in_size) / 4;

    snap_x_off = 0 + eps / 2;
    snap_y_off = (y_in_size - snap_l) / 2;
    cutter_z_size = middle_rant_h + additional_top_thickness;
    snap_z_off = z_in_size;

    snap_x2_off = x_in_size - eps / 2;
    snap_y2_off = (y_in_size + snap_l) / 2;
    X(snap_x_off) Y(snap_y_off) Z(snap_z_off) turnXY(-90) turnYZ(180) snap_linear(h = snap_z, w = snap_w, l = snap_l);
    X(snap_x2_off) Y(snap_y2_off) Z(snap_z_off) turnXY(90) turnYZ(180) snap_linear(h = snap_z, w = snap_w, l = snap_l);

    // buttons protectors
    // %X(button_x_offset) Y(button1_y_offset) Z(0) button_protection();
}

module cars_pilot_bottom()
{
    // add snaps!
    snap_z = 7;
    snap_l = 20;
    thickness_c = 1 + (thickness_coeff - 1) / 2;
    box_th = (x_out_size - x_in_size) / 2;
    snap_w = (x_out_size - x_in_size) / 4;

    snap_x_off = 0 + eps;
    snap_y_off = (y_in_size - snap_l) / 2;
    cutter_z_size = middle_rant_h + additional_top_thickness;
    snap_z_off = z_in_size;

    snap_x2_off = x_in_size - eps;
    snap_y2_off = (y_in_size + snap_l) / 2;
    difference() {
        no_cut_cars_pilot();
        union() {
            pilot_cutter();
            X(snap_x_off - eps / 2) Y(snap_y_off) Z(snap_z_off) turnXY(-90) turnYZ(180) snap_linear_complement(h = snap_z, w = snap_w, l = snap_l);
            X(snap_x2_off + eps / 2) Y(snap_y2_off) Z(snap_z_off) turnXY(90) turnYZ(180) snap_linear_complement(h = snap_z, w = snap_w, l = snap_l);
        }
    }
    // battery
    battery_holder_d = 11;
    battery_holder_l = 20;
    X(battery_holder_d / 2) Y((y_in_size) / 2) Z(battery_holder_l / 2 - z_diff * 3) intersection() {
        turnYZ(90) tube(d = battery_holder_d, h = 20, wall = 1);
        turnXZ(-45) TORIGHT() box(x = battery_holder_l, y = battery_holder_l + eps, z = battery_holder_l);
    }
}

// rendering

turnXZ(180) cars_pilot_upper();
Y(100) cars_pilot_bottom();

/*X(-button_x_offset - button_d) Y(button2_y_offset) turnXZ(180) turnXY(90)*/ buttons();
