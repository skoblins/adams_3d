//include <Round-Anything/polyround.scad>
use <smooth-prim/smooth_prim.scad>

x_in_size = 65;
y_in_size = 90;
z_in_size = 20;

thickness = 4;
holder_stripe_w = 5;

module inside_empty_space() {
    cube([x_in_size, y_in_size + 10, z_in_size]);
}

module opening_for_te_screen(){
    translate([holder_stripe_w, holder_stripe_w, 0]) cube([x_in_size - holder_stripe_w * 2, y_in_size + 10, z_in_size + 10]);
}

module opening_for_charger() {
    translate([0.165 * x_in_size, -10, 0.125 * z_in_size]) cube([0.66 * x_in_size, y_in_size + 10, 0.75 * z_in_size]);
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
}

$fn=100;
//minkowskiRound(0.7, 0.1, 1, [100, 150, 100]){
holder_box();
//}