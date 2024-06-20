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
        box(x = 25, y = 25, z = 25);
    }
}
