$fn = 100;

eps = 0.1;

_h = 10;
_th = 7;
_d = 23;
_small_d = 4.9;

difference() {
    difference() {
        cylinder(h = _h, d = _d + _th);
        translate([0, 0, -eps / 2]) cylinder(h = _h + eps, d = _d);
    }

    union() {
        translate([0, 0, _small_d / 2]) rotate([90, 0 , 0]) translate([0, 0, _th / 2]) cylinder(h = _th * 2, d = _small_d);
        rotate([0, 0, 120]) translate([0, 0, _small_d / 2]) rotate([90, 0 , 0]) translate([0, 0, _th / 2]) cylinder(h = _th * 2, d = _small_d);
        rotate([0, 0, 240]) translate([0, 0, _small_d / 2]) rotate([90, 0 , 0]) translate([0, 0, _th / 2]) cylinder(h = _th * 2, d = _small_d);
    }
}
