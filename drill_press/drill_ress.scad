use <BOSL2/linear_bearings.scad>
include <constructive/constructive-compiled.scad>
$fn = 50;

assemble() {
    // // Ball Bearing in the middle
    add() cylinder(h=15, d=44, center=true);
    remove() {
        cylinder(h=margin(7, 1), d=margin(22, 1), center=true);
        cylinder(h=margin(18, 1), d=margin(8, 1), center=true);
    }
    // Arms
    pieces(4) turnXY(every(90)) stack(TOLEFT) {
        TOLEFT() box(x = 125, y = 15, z = 15)
        linear_bearing_housing(d=19, l=29, wall=2, tab=6, screwsize=2.5);
    }
}
