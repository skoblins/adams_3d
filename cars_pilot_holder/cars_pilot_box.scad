use <smooth-prim/smooth_prim.scad>
include <constructive/constructive-compiled.scad>

$fn = 100;

// paramters
eps = 0.5;
x_in_size = 28 + eps;
y_in_size = 34 + eps;
z_in_size = 10.1 + eps;
thickness_coeff = 1.15; // will determine how thick is the shell, in relation to inside size
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
diode_x_offset = 17.25;
diode_y_offset = 32.38; //

// buttons common
button_d = 5; //[mm]
button_x_offset = x_in_size - eps/2 - 6.36 - 1.75; // with regards to the center of the button

// button1
button1_y_offset = 27.74 - button_d / 2;//

// button2
button2_y_offset = 16.68 - button_d / 2; //

// hole for keys
hole_in_d = 10;
hole_out_d = 20;

// modules
module inside() {
    TORIGHT() TOUP() TOREAR() chamfer(-1,-1,-1, fnCorner=60) box(x = x_in_size, y = y_in_size, z = z_in_size);
}

module outside() {
    translate([x_offset, y_offset, z_offset]) TORIGHT() TOUP() TOREAR() chamfer(-2,-2,-2, fnCorner=60) color("gray") box(x = x_out_siz, y = y_out_siz, z = z_out_siz + 1);/*cube([x_out_siz, y_out_siz, z_out_siz]);*/
    //button_rants();
}

module button_rants() {
    // button1 rant
    translate([button_x_offset - 1, button1_y_offset - 1, z_in_size - eps/2]) TORIGHT() TOUP() TOREAR() chamfer(-0.5, -0.5, -0.5, fnCorner = 30) color("green") box(x = button_d + 2, y = button_d + 2, z = 2);
    
    // button2 rant
    translate([button_x_offset - 1, button2_y_offset - 1, z_in_size - eps/2]) TORIGHT() TOUP() TOREAR() chamfer(-0.5, -0.5, -0.5, fnCorner = 30) color("red") box(x = button_d + 2, y = button_d + 2, z = 2);
}

module diode_cutout() {
    translate([diode_x_offset, diode_y_offset, -z_offset]) cylinder(h = z_in_size + 1 + eps/*not too important...*/, d = diode_d + eps);
}

module buttons_cutout() {
    eps = 0.25;
    //button1
    translate([button_x_offset - eps/2, button1_y_offset - eps/2, z_in_size - eps/2]) cube(size=[button_d + eps, button_d + eps, button_d]);
    ball(d=3);
    //button2
    translate([button_x_offset - eps/2, button2_y_offset - eps/2, z_in_size - eps/2]) cube(size=[button_d + eps, button_d + eps, button_d]);
}

module hole_for_key_ring() {
    chamfer(-2, -2, fnCorner=60) color("gray") tube(d = hole_out_d, h = z_out_siz * 0.5, wall = 4);
}

module button() {
    rant_size = 3;
    cube(size=[button_d, button_d, 4]);
    translate([-rant_size / 2, -rant_size / 2 , -1.5]) cube(size=[button_d + rant_size, button_d + rant_size, 2.5]);
}

module buttons() {
    // loose buttons
    translate([x_out_siz + 10, y_out_siz + 10, 0]) color("green") button();
    translate([x_out_siz + 15 + button_d, y_out_siz + 10, 0]) color("red") button();
}

// rendering
assemble() {
     add() outside();
     remove() {
        inside();
        diode_cutout();
        buttons_cutout();
    }
    translate([x_in_size / 2, y_in_size + hole_out_d / 2, z_offset + z_in_size / 3.5]) TOUP() hole_for_key_ring();
buttons();
}