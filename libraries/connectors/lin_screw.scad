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

module segment_with_square_nuts(length, height, width, screw_head_h, screw_head_d, screw_d, nut_height, nut_width, clearance = 0.2, anchor = CENTER, spin = 0, orient = UP) {
    assert(nut_height < height, "Nut height must be less than segment height");
    eps = 0.01;
    attachable(anchor = anchor, spin = spin, orient = orient, size = [length, width, height]) {
        union() {
            right(-length/2) back(-width/2) up(-height/2) difference() {
                union() {
                    linear_extrude(height/2 - clearance/2)
                    polygon(points = [
                        [0,0],
                        [length, 0],
                        [length, width * 1/2],
                        [length * 8/9, width * 3/4],
                        [length * 7/9, width * 1/4],
                        [length * 6/9, width * 1/4],
                        [length * 5/9, width * 3/4],
                        [length * 4/9, width * 3/4],
                        [length * 3/9, width * 1/4],
                        [length * 2/9, width * 1/4],
                        [length * 1/9, width * 3/4],
                        [0, width * 1/2]
                    ]);
                    #up(height/2 - clearance/2)linear_extrude(clearance)
                    polygon(points = [
                        [0,0],
                        [length, 0],
                        [length, width * 1/2],
                        [length * 8/9, width * 1/4],
                        [length * 15/18, width * 1/2],
                        [length * 7/9, width * 1/4],
                        [length * 6/9, width * 1/4],
                        [length * 11/18, width * 1/2],
                        [length * 5/9, width * 1/4],
                        [length * 4/9, width * 1/4],
                        [length * 7/18, width * 1/2],
                        [length * 3/9, width * 1/4],
                        [length * 2/9, width * 1/4],
                        [length * 3/18, width * 1/2],
                        [0, width * 1/2]
                    ]);
                    up(height/2 + clearance/2)linear_extrude(height/2 - clearance/2)
                    polygon(points = [
                        [0,0],
                        [length, 0],
                        [length, width * 1/2],
                        [length * 8/9, width * 1/4],
                        [length * 7/9, width * 3/4],
                        [length * 6/9, width * 3/4],
                        [length * 5/9, width * 1/4],
                        [length * 4/9, width * 1/4],
                        [length * 3/9, width * 3/4],
                        [length * 2/9, width * 3/4],
                        [length * 1/9, width * 1/4],
                        [0, width * 1/2]
                    ]);
                }
                union(){
                    right(length * 1/2) back(nut_width/2 - eps) up(height/2) {
                        cube([nut_height, nut_width + eps, nut_height], center = true);
                        xrot(90) up(-width/2) cylinder(h = width, d = screw_d, center = true, $fn = 50);
                    }
                }
            }
        }
        children();
    }
}

module segment_compliment_with_bolts(length, height, width, screw_head_h, screw_head_d, screw_d, nut_height, nut_width, clearance = 0.2, anchor = CENTER, spin = 0, orient = UP) {
    assert(screw_head_d < height, "Screw head diameter must be less than segment height");
    eps = 0.01;
    attachable(anchor = anchor, spin = spin, orient = orient, size = [length, width, height]) {
        union() {
            right(-length/2) back(-width/2) up(-height/2) difference() {
                union() {
                    linear_extrude(height/2 - clearance/2)
                    polygon(points = [
                        [0,0],
                        [length, 0],
                        [length, width * 1/2],
                        [length * 8/9, width * 1/4],
                        [length * 7/9, width * 3/4],
                        [length * 6/9, width * 3/4],
                        [length * 5/9, width * 1/4],
                        [length * 4/9, width * 1/4],
                        [length * 3/9, width * 3/4],
                        [length * 2/9, width * 3/4],
                        [length * 1/9, width * 1/4],
                        [0, width * 1/2],
                    ]);
                    #up(height/2 - clearance/2)linear_extrude(clearance)
                    polygon(points = [
                        [0,0],
                        [length, 0],
                        [length, width * 1/2],
                        [length * 8/9, width * 1/4],
                        [length * 15/18, width * 1/2],
                        [length * 7/9, width * 1/4],
                        [length * 6/9, width * 1/4],
                        [length * 11/18, width * 1/2],
                        [length * 5/9, width * 1/4],
                        [length * 4/9, width * 1/4],
                        [length * 7/18, width * 1/2],
                        [length * 3/9, width * 1/4],
                        [length * 2/9, width * 1/4],
                        [length * 3/18, width * 1/2],
                        [length * 1/9, width * 1/4],
                        [0, width * 1/2],
                        [0, 0]
                    ]);
                    up(height/2 + clearance/2)linear_extrude(height/2 - clearance/2)
                    polygon(points = [
                        [0,0],
                        [length, 0],
                        [length, width * 1/2],
                        [length * 8/9, width * 3/4],
                        [length * 7/9, width * 1/4],
                        [length * 6/9, width * 1/4],
                        [length * 5/9, width * 3/4],
                        [length * 4/9, width * 3/4],
                        [length * 3/9, width * 1/4],
                        [length * 2/9, width * 1/4],
                        [length * 1/9, width * 3/4],
                        [0, width * 1/2],
                    ]);
                }
                union(){
                    right(length * 1/2) back(screw_head_h / 2) up(height/2) xrot(90) {
                        up(eps)cylinder(h = screw_head_h, d = screw_head_d, center = true, $fn = 50);
                        up(-width/2) cylinder(h = width, d = screw_d, center = true, $fn = 50);
                    }
                }
            }
        }
        children();
    }
}

module segment_with_square_nuts_correctly_aligned(length, height, width, screw_head_h, screw_head_d, screw_d, nut_height, nut_width, clearance = 0.2, anchor = CENTER, spin = 0, orient = UP) {
    left(1/2*length) right(13/72 * length) up(1/3*height - 1/2*height-2*clearance) segment_with_square_nuts(length, height, width, screw_head_h, screw_head_d, screw_d, nut_height, nut_width, clearance, anchor, spin, orient)
    children();
}

module segment_compliment_with_bolts_correctly_aligned(length, height, width, screw_head_h, screw_head_d, screw_d, nut_height, nut_width, clearance = 0.2, anchor = CENTER, spin = 0, orient = UP) {
    left(1/2*length) right(13/72 * length) up(1/3*height - 1/2*height-2*clearance) segment_compliment_with_bolts(length, height, width, screw_head_h, screw_head_d, screw_d, nut_height, nut_width, clearance, anchor, spin, orient)
    children();
}

// down(0){
//     segment_with_square_nuts(length = _length, height = _height, width = _width, screw_head_h = _screw_head_h, screw_head_d = _screw_head_d, screw_d = _screw_d, nut_height = _nut_height, nut_width = _nut_width, clearance = _clearance);
//     zrot(180) %segment_compliment_with_bolts(length = _length, height = _height, width = _width, screw_head_h = _screw_head_h, screw_head_d = _screw_head_d, screw_d = _screw_d, nut_height = _nut_height, nut_width = _nut_width, clearance = _clearance);
// }

module antibend_rod_conn(length, width, height, screw_d = 3, screw_head_h = 3, screw_head_d = 5.5, nut_h = 2, nut_d = 5.5, anchor = CENTER, spin = 0, orient = UP) {
    eps = 0.01;
    clearance = 0.4;
    if(screw_head_d > screw_d) {
        echo("screw recommended length (with the head): ", height);
    } else {
        echo("screw recommended length (with the head): ", height + screw_head_h);
    }
    attachable(anchor = anchor, spin = spin, orient = orient, size = [length, width, height]) {
        diff("hole") {
            cuboid([length, width, height])
            tag("hole") cuboid([length + eps, width/2, height/2])
            tag("hole") cyl(d = screw_d + clearance, h = height + eps, teardrop = true, $fn = 50)
            attach(TOP, TOP, inside = true) tag("hole") cyl(d = screw_head_d + clearance, h = screw_head_h, teardrop = true, $fn = 50);
            attach(BOTTOM, BOTTOM, inside = true) down(eps) tag("hole") cube([nut_d + clearance, nut_d + clearance, nut_h + clearance]);
        }
        children();
    }
}

module antibend_rod_conn_inside(length, width, height, screw_d = 3, anchor = CENTER, spin = 0, orient = UP) {
    eps = 0.01;
    clearance = 0.4;
    attachable(anchor = anchor, spin = spin, orient = orient, size = [length, width, height]) {
        diff() {
            cuboid([length, width/2 - clearance, height/2 - clearance])
            tag("remove") cyl(d = screw_d + clearance, h = height + eps, teardrop = true, $fn = 50);
        }
        children();
    }
}

// %down(50) right(50) {
//     yrot(90) antibend_rod_conn(30, 20, 20);
//     right(50) antibend_rod_conn_inside(30, 20, 20);
// }