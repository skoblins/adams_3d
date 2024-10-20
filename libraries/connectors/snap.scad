-include <constructive/constructive-compiled.scad>

module _snap_round_shape(h, d, bulge) {
    stack(TOUP) {
        TOUP() tube(h = h * 0.75, d1 = d, d2 = d * bulge, solid = true, $fn = 50)
        tube(h = h * 0.25, d1 = d * bulge, d2 = d * 0.9, solid = true, $fn = 50);
    }
}

module snap_round(h, d, bulge) {
    difference() {
        _snap_round_shape(h, d, bulge);
        {
            TOUP() Z(h * 0.25 + 0.1) box(x = d * bulge + 0.1, y = d * 0.2, z = h * 0.75);
            TOUP() turnXY(90) Z(h * 0.25 + 0.1) box(x = d * bulge + 0.1, y = d * 0.2, z = h * 0.75);
        }
    }
}

module snap_round_complement(h, d, bulge) {
    eps = 0.1;
    _snap_round_shape(h + eps, d + eps, bulge);
}

module snap_shaft(h, d) {
    eps = 0.1;
    difference() {
        stack(TOUP) {
            TOUP() tube(h = h, d = d, solid = true, $fn = 100)
            tube(h = max(h * 0.15, 0.4), d = max(d * 1.15, 0.6), solid = true, $fn = 100);
        }
        {
            TOUP() Z(h * 0.8) box(x = d * 1.15 + 0.1, y = d * 0.2, z = h * 0.85);
            TOUP() turnXY(90) Z(h * 0.8) box(x = d * 1.15 + 0.1, y = d * 0.2, z = h * 0.85);
            TOUP() Z(h * 0.8) tube(h = h, d = d * 0.8, solid = true, $fn = 20);
        }
    }
}

module snap_shaft_complement(h, d) {
    clearance = 0.4;
    stack(TOUP) {
        TOUP() tube(h = h, d = d + clearance, solid = true, $fn = 100)
        Z(-clearance/2) tube(h = max(h * 0.15, 0.4) + clearance, d = max(d * 1.15, 0.6) + clearance, solid = true, $fn = 100);
    }    
}


module snap_linear(h, w, l) {
    snap_depth = 1.4;
    turnXZ(90) linear_extrude(l) polygon(points = [
        [0, 0],
        [h, 0],
        [h - snap_depth * w, w * snap_depth],
        [h - snap_depth * w, w * snap_depth],
        [h - snap_depth * 1.33 * w, w],
        [0, w]
    ]);
}

module snap_linear_complement(h, w, l) {
    eps = 0.2;
    h_clearance = 0.4;
    snap_depth = 1.4;
    X(eps / 2) turnXZ(90) linear_extrude(l + eps) polygon(points = [
        [0, 0],
        [h + h_clearance + eps, 0],
        [h + eps - snap_depth * (w + eps), (w + eps) * snap_depth],
        [h - snap_depth * (w + eps), (w + eps) * snap_depth],
        [h - snap_depth * 1.33 * (w + eps), w + eps],
        [0, w + eps]
    ]);
}


Y(0)  snap_round(3, 2.5, 1.2);
Y(5)  clear(grey) snap_round_complement(3, 2.5, 1.2);
Y(10) snap_linear(h = 10, w = 2, l = 20);
Y(15) clear(grey) snap_linear_complement(h = 10, w = 2, l = 20);
Y(20) snap_linear(h = 5, w = 1, l = 5);
Y(25) clear(grey) snap_linear_complement(h = 5, w = 1, l = 5);

Y(30)  snap_shaft(3, 2.5);
Y(35)  clear(grey) snap_shaft_complement(3, 2.5);
