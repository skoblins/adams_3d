include <reed.scad>

module base_pipe(l, d, thickness) {
	difference() {
		cylinder(h=l, d=d+thickness*2);
		translate([0,0,-l*0.01]) cylinder(h=l*1.1, d=d);
	}
}

module pipe_reed_socket(l, d, thickness) {
	// params are local dimensions, not of the entire pipe!
	cylinder(h=l, d=d+2*thickness);
}

module pipe(l, d, thickness) {
	base_pipe(l, d, thickness);
	translate([0,0,l]) pipe_reed_socket(3*d, d, 1.5*thickness);
}