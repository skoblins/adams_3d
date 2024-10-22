include <BOSL2/std.scad>

_clearance = 0.4;

_length = 30;
_height = 15;
_width = 15;

_nut_height = 5 + _clearance;
_nut_width = 2.5;

_screw_head_d = 5 + _clearance;
_screw_head_h = 2 + _clearance;
_screw_d = 3 + _clearance;

module segment_with_square_nuts(length, height, width, screw_head_h, screw_head_d, screw_d, nut_height, nut_width, clearance, anchor = CENTER, spin = 0, orient = UP) {
    assert(nut_height < height, "Nut height must be less than segment height");
    eps = 0.01;
    attachable(cp = [0, width/4, -height/4], anchor = anchor, spin = spin, orient = orient, size = [length, width, height]) {
        union() {
            right(-_length/2) back(-_width/2) up(-_height/2) difference() {
                union() {
                    linear_extrude(height/2 - clearance/2)
                    polygon(points = [
                        [0,0],
                        [length * 1/3, width * 1/2],
                        [length * 2/3, width * 1/2],
                        [length * 3/3, width],
                        [0, width]
                    ]);
                    up(height/2 + clearance/2) linear_extrude(height/2 - clearance/2)
                    polygon(points = [
                        [0,0],
                        [0,width],
                        [length * 1/3, width * 1/2],
                        [length * 2/3, width * 1/2],
                        [length * 3/3, 0],
                        [length, 0]
                    ]);
                }   
                union(){
                    right(length * 1/2) back(nut_width/2 - eps) up(height/2) {
                        cube([nut_height, nut_width + eps, nut_height], center = true);
                        xrot(90) up(-width/2) cylinder(h = width, d = screw_d, center = true, $fn = 50);
                    }
                    right(length * 1/2) up(height/2) back(width - screw_head_h/2) ycyl(h = screw_head_h+eps, d = screw_head_d, $fn = 50);
                }
            }
        }
        children();
    }
}

module segment_compliment_with_bolts(length, height, width, screw_head_h, screw_head_d, screw_d, nut_height, nut_width, clearance, anchor = CENTER, spin = 0, orient = UP) {
    assert(screw_head_d < height, "Screw head diameter must be less than segment height");
    eps = 0.01;
    attachable(cp = [length/20, 0, 0], anchor = anchor, spin = spin, orient = orient, size = [length, width, height]) {
        union() {
            zrot(180) right(-length/2) back(-width/2) up(-height/2) difference() {
                union() {
                    linear_extrude(height/2 - clearance/2)
                    polygon(points = [
                        [0,0],
                        [length * 1/3, width * 1/2],
                        [length * 2/3, width * 1/2],
                        [length * 3/3, width],
                        [0, width],
                        [0, 0],
                    ]);
                    up(height/2 + clearance/2) linear_extrude(height/2 - clearance/2)
                    polygon(points = [
                        [0,width],
                        [length * 1/3, width * 1/2],
                        [length * 2/3, width * 1/2],
                        [length * 3/3, 0],
                        [0, 0],
                        [0, width]
                    ]);
                }
                union(){
                    right(length * 1/2) back(screw_head_h / 2) up(height/2) xrot(90) {
                        up(eps)cylinder(h = screw_head_h, d = screw_head_d, center = true, $fn = 50);
                        up(-width/2) cylinder(h = width, d = screw_d, center = true, $fn = 50);
                    }
                    right(length * 1/2) up(height/2) back(width - nut_width/2) cube([nut_height, nut_width + eps, nut_height], center = true);
                }
            }
        }
        children();
    }
}

// %down(50){
//     segment_with_square_nuts(_length, _height, _width, _nut_height, _nut_width, _screw_d, _clearance);
//     segment_compliment_with_bolts(_length, _height, _width, _screw_head_h, _screw_head_d, _screw_d, _clearance);
// }

module antibend_rod_conn(length, width, heigth, screw_d = 3, screw_head_h = 3, screw_head_d = 5.5, nut_h = 2, nut_d = 5.5, anchor = CENTER, spin = 0, orient = UP) {
    eps = 0.01;
    clearance = 0.4;
    if(screw_head_d > screw_d) {
        echo("screw recommended length (with the head): ", heigth);
    } else {
        echo("screw recommended length (with the head): ", heigth + screw_head_h);
    }
    attachable(anchor = anchor, spin = spin, orient = orient, size = [length, width, heigth]) {
        diff("hole") {
            cuboid([length, width, heigth])
            tag("hole") cuboid([length + eps, width/2, heigth/2])
            tag("hole") cyl(d = screw_d + clearance, h = heigth + eps, teardrop = true, $fn = 50)
            attach(TOP, TOP, inside = true) tag("hole") cyl(d = screw_head_d + clearance, h = screw_head_h, teardrop = true, $fn = 50);
            attach(BOTTOM, BOTTOM, inside = true) down(eps) tag("hole") cube([nut_d + clearance, nut_d + clearance, nut_h + clearance]);
        }
        children();
    }
}

module antibend_rod_conn_inside(length, width, heigth, screw_d = 3, anchor = CENTER, spin = 0, orient = UP) {
    eps = 0.01;
    clearance = 0.4;
    attachable(anchor = anchor, spin = spin, orient = orient, size = [length, width, heigth]) {
        diff() {
            cuboid([length, width/2 - clearance, heigth/2 - clearance])
            tag("remove") cyl(d = screw_d + clearance, h = heigth + eps, teardrop = true, $fn = 50);
        }
        children();
    }
}

// %down(50) right(50) {
//     yrot(90) antibend_rod_conn(30, 20, 20);
//     right(50) antibend_rod_conn_inside(30, 20, 20);
// }