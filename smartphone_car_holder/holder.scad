//include <Round-Anything/polyround.scad>
use <smooth-prim/smooth_prim.scad>

x_in_size = 85;
y_in_size = 79;
z_in_size = 17;

thickness = 6;
holder_stripe_w = 5;

module inside_empty_space() {
    SmoothCube([x_in_size, y_in_size + 10, z_in_size], 3);
}

module opening_for_te_screen(){
    translate([holder_stripe_w, holder_stripe_w, 0]) SmoothCube([x_in_size - holder_stripe_w * 2, y_in_size + 10, z_in_size + 10], 5);
}

module opening_for_charger() {
    translate([0.165 * x_in_size, -10, 0.125 * z_in_size]) SmoothCube([0.66 * x_in_size, y_in_size + 10, 0.75 * z_in_size], 5);
}

module opening_for_loudspeakers() {
    translate ([x_in_size * 0.75 / 6, 10, - thickness]) SmoothXYCube([x_in_size * 0.75, 18, thickness + 2], 5);
}

module outside() {
    translate([-thickness/2, -thickness/2, -thickness/2]) SmoothCube([x_in_size + thickness, y_in_size + thickness, z_in_size + thickness], 5);
}

module extension_upwards() {
    // we have to leave the opening for the finger authorization sensor
    difference() {
        // a normal extension
        translate([x_in_size / 4, y_in_size - 5, -thickness/2])
            SmoothXYCube([x_in_size / 2, y_in_size, thickness/2], 5);
        // opening is between 11cm and 13 cm from the bottom of the smartphone, and 20mm wide
        translate([(x_in_size - 20) / 2, 105, -thickness/2 - 0.1])
            SmoothXYCube([20, 20, thickness], 4);
        }
}

module holder_box() {
    difference() {
        outside();
        inside_empty_space();
        opening_for_te_screen();
        opening_for_charger();
        opening_for_loudspeakers();
    }
    extension_upwards();
}

rod_width = 10;
rod_breadth = 6;
rod_len = 45;
rod_degree = 60;

module rod(rod_len){
    rotate([90, 180, 90]) {
        linear_extrude(rod_width) {
            polygon([
                [0, 0],
                [rod_breadth, 0],
                [cos(rod_degree) * rod_len + rod_breadth, sin(rod_degree) * rod_len],
                [cos(rod_degree) * rod_len, sin(rod_degree) * rod_len],
                [0, 0]
            ]);
        }
    }
}

module clips() {
    rod(rod_len);
    translate([x_in_size / 3, 0, 0])
        rod(rod_len);

    // second row
    translate([0, -10   , 0]) {
        rod(rod_len/3);
        translate([x_in_size / 3, 0, 0])
            rod(rod_len/3);
    }
}

module clips_with_plate() {
    plate_x_siz = x_in_size / 2;
    plate_y_siz = y_in_size * 0.33;
    translate([-2/*don't know why*/, -plate_y_siz, -thickness/4 /*thickness of the upper part*/]) SmoothXYCube([plate_x_siz, plate_y_siz, thickness/4], 5);
    clips();
}

$fn=100;
holder_box();
translate([150, 0, 0]) clips_with_plate();
