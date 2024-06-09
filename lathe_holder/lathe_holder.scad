$fn = 100;

eps = 0.8;
1st_in_diameter = 37.66 + eps; //[mm]
1st_in_height = 15;
2nd_1st_d = 30.04 + eps;
2nd_2nd_d = 25.5 + eps;
2nd_h = 6.5;
3rd_d = 8.12 + eps;
3rd_h = 8;

module inside() {
    translate([0, 0, -eps]) cylinder(h = 1st_in_height + eps, d = 1st_in_diameter);
    translate([0, 0, 1st_in_height - eps]) cylinder(h = 2nd_h + eps, d1 = 2nd_1st_d, d2 = 2nd_2nd_d);
    translate([0, 0, 1st_in_height + 2nd_h - eps]) cylinder(h = 3rd_h + eps, d1 = 3rd_d, d2 = 0);
}

module outside() {
    h = (1st_in_height + 2nd_h + 3rd_h) * 1.1;
    d = 1st_in_diameter * 1.3;
    cylinder(h = h, d = d);
    translate([0, 0, h - eps]) cylinder(h = 1.5 * h + eps, d = 8);
}

difference() {
    outside();
    inside();
}
