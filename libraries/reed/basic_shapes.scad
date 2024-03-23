module base_pipe(l, d, thickness_bottom, thickness_top) {
    difference() {
        cylinder(h=l, d1=d+thickness_bottom*2, d2=d+thickness_top*2);
        translate([0,0,-l*0.01]) cylinder(h=l*1.1, d=d);
    }
}

module base_pipe_b(l, d_in, d_out) {
    eps = 0.01;
    difference() {
        cylinder(h = l, d = d_out);
        translate([0, 0, -eps/2]) cylinder(h = l + eps, d = d_in);
    }
}

