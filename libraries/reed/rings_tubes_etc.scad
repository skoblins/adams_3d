module leaf_fastener_tube(h, d_in, thickness) {
	eps = 0.01;
	difference() {
		cylinder(h = h, d = d_in + 2 * thickness);
		translate([0,0,-eps / 2 ]) cylinder(h = h + eps, d = d_in);
	}
}