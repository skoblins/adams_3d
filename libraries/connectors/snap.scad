include <constructive/constructive-compiled.scad>

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

module snap_linear(h, w, l) {
    turnXZ(90) linear_extrude(l) polygon(points = [[0, 0], [h, 0], [h - 1.5 * w, w * 1.5], [h - 1.7 * w, w * 1.5], [h - 1.7 * w, w], [0, w]]);
}

module snap_linear_complement(h, w, l) {
    eps = 0.2;
    X(eps / 2) turnXZ(90) linear_extrude(l + eps) polygon(points = [[0, 0], [h + eps, 0], [h + eps - 1.5 * (w + eps), (w + eps) * 1.5], [h - 1.7 * (w + eps), (w + eps) * 1.5], [h - 1.7 * (w + eps), w + eps], [0, w + eps]]);
}


X(0)  snap_round(3, 2.5, 1.2);
X(5)  clear(grey) snap_round_complement(3, 2.5, 1.2);
Y(10) snap_linear(h = 10, w = 2, l = 20);
Y(15) clear(grey) snap_linear_complement(h = 10, w = 2, l = 20);
Y(20) snap_linear(h = 5, w = 1, l = 5);
Y(25) clear(grey) snap_linear_complement(h = 5, w = 1, l = 5);
