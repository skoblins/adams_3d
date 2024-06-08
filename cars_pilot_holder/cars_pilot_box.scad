use <smooth-prim/smooth_prim.scad>
$fn = 100;

// paramters
eps = 0.5;
x_in_size = 28 + eps;
y_in_size = 34 + eps;
z_in_size = 10.1 + eps;
thickness_coeff = 1.3; // will determine how thick is the shell, in relation to inside size
rounding = (x_in_size + y_in_size + z_in_size) / 20;
battery_z_offset = -1.5;

x_out_siz = x_in_size * thickness_coeff;
y_out_siz = y_in_size * thickness_coeff;
z_out_siz = z_in_size * thickness_coeff;

x_diff = x_in_size * (thickness_coeff - 1);
y_diff = y_in_size * (thickness_coeff - 1);
z_diff = z_in_size * (thickness_coeff - 1);

x_offset = -x_diff / 2;
y_offset = -y_diff / 2;
z_offset = -z_diff / 2;

// diode
diode_d = 3.1; //[mm]
diode_x_offset = 17;
diode_y_offset = 32.38; //

// buttons common
button_d = 5; //[mm]
button_x_offset = x_in_size - eps/2 - 6.36; // with regards to the center of the button

// button1
button1_y_offset = 27.74 - button_d / 2;//

// button2
button2_y_offset = 16.68 - button_d / 2; //

// hole for keys
hole_in_d = 10;
hole_out_d = 20;

// modules
module inside() {
    SmoothXYCube([x_in_size, y_in_size, z_in_size], rounding);
}

module outside() {
    translate([x_offset, y_offset, z_offset]) SmoothXYCube([x_out_siz, y_out_siz, z_out_siz], rounding);
}

module diode_cutout() {
    translate([diode_x_offset, diode_y_offset, -z_offset]) cylinder(h = z_in_size + eps/*not too important...*/, d = diode_d + eps);
}

module buttons_cutout() {
    //button1
    translate([button_x_offset, button1_y_offset, z_in_size - eps/2]) cube(size=[button_d, button_d, button_d]);
    //button2
    translate([button_x_offset, button2_y_offset, z_in_size - eps/2]) cube(size=[button_d, button_d, button_d]);
}

module hole_for_key_ring() {
    difference() {
        cylinder(h = z_out_siz, d = hole_out_d);
        translate([0, 0, -eps/2]) cylinder(h = z_out_siz + eps, d = hole_in_d);
    }
}

module button() {
    rant_size = 3;
    cube(size=[button_d, button_d, 3]);
    translate([-rant_size / 2, -rant_size / 2 , -3.5]) cube(size=[button_d + rant_size, button_d + rant_size, 4]);
}

module buttons() {
    // loose buttons
    translate([x_out_siz + 10, y_out_siz + 10, 0]) button();
    translate([x_out_siz + 15 + button_d, y_out_siz + 10, 0]) button();
}

// rendering
difference() {
    outside();
    union() {
        inside();
        diode_cutout();
        buttons_cutout();
    }
}
translate([x_in_size / 2, y_in_size + hole_out_d / 2, z_offset]) hole_for_key_ring();

buttons();
