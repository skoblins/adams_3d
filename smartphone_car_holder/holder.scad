//include <Round-Anything/polyround.scad>
use <smooth-prim/smooth_prim.scad>

x_in_size = 85;
y_in_size = 90;
z_in_size = 16;

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

module outside() {
    translate([-thickness/2, -thickness/2, -thickness/2]) SmoothCube([x_in_size + thickness, y_in_size + thickness, z_in_size + thickness], 5);
}

module holder_box() {
    difference() {
        outside();
        inside_empty_space();
        opening_for_te_screen();
        opening_for_charger();
    }
    // extension upwards
    translate([x_in_size / 4, y_in_size - 5, -thickness/2])
        SmoothXYCube([x_in_size / 2, y_in_size, thickness/2], 5);
}

rod_width = 10;
rod_heigth = 6;
rod_size = 30;

module rod(){
    rotate([90, 180, 90]) {
        linear_extrude(rod_width) {
            polygon([
                [0, 0],
                [rod_heigth, 0],
                [rod_size, rod_size],
                [rod_size, rod_size + rod_heigth],
                [0, 0]
            ]);
        }
    }
}

module clips() {
    rod();
    translate([x_in_size / 3, 0, 0])
        rod();
}

$fn=100;
holder_box();
translate([x_in_size / 3 - rod_width / 2, y_in_size * 0.95 * 2, 0]) clips();
