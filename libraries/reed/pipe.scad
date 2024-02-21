eps = 0.02;

module base_pipe(l, d, thickness) {
	difference() {
		cylinder(h=l, d=d+thickness*2);
		translate([0,0,-l*0.01]) cylinder(h=l*1.1, d=d);
	}
}

module pipe_reed_socket(l, d1, d2, reed_d1, reed_d2) {
	// params are local dimensions, not of the entire pipe!
	difference(){
		cylinder(h=l, d1=d1, d2=d2);
		translate([0,0,-eps/2]) cylinder(h=l+eps, d1=reed_d1, d2=reed_d2);
	}
}


module curbs(l, d1, d2, flute_count) {
	for(i=[1:flute_count]) {
        translate([0,0,(i-1)*l/flute_count]){
            // base_pipe(l=l/flute_count/2, d=d1, thickness=(d2-d1)/2);
            difference(){
            	cylinder(h=l/flute_count/2, d1=d1, d2=d2);
            	translate([0,0,-eps]) cylinder(h=l+eps, d=d1);
            }
        }
    }
}

module pipe_socket(l, d1, d2) {
	base_pipe(l, d1, (d2-d1)/2);
	curbs(l, d2, d2*1.1, 4);
}

module pipe_horn_socket(l, d1, d2) {
	base_pipe(l, d1, (d2-d1)/2);
}

module holes_cutter(l, d, thickness, holes) {
	translate([0,holes[0]*l,0]) rotate([0,-20,0]) cylinder(h=d+thickness+eps, d1=d*0.7, d2=d*1.3);
	for(i = [1:2]) {
		hole_loc = holes[i];
		translate([0,hole_loc*l,0]) cylinder(h=d+thickness+eps, d1=d*0.7, d2=d*1.3);
	}
	translate([0,holes[3]*l,0]) rotate([0,180,0]) cylinder(h=d+thickness+eps, d1=d*0.7, d2=d*1.3);
	for(i = [4:7]) {
		hole_loc = holes[i];
		translate([0,hole_loc*l,0]) cylinder(h=d+thickness+eps, d1=d*0.7, d2=d*1.3);
	}
	translate([0,holes[8]*l,0]) rotate([0,180,0]) cylinder(h=d+thickness+eps, d1=d*0.7, d2=d*1.3);
}

module pipe(l, d, thickness, holes) {
	
	difference() {
		base_pipe(l, d, thickness);
		translate([0, 0, 0]) rotate([90,0,0]) holes_cutter(l, d, thickness, holes);
	}
	
	reed_socket_len = 3*d;
	pipe_socket_len=36;
	horn_socket_len=20;
	horn_pos = -horn_socket_len;

	translate([0,0,l]) pipe_reed_socket(reed_socket_len, 16, 24, 6, 8);
	translate([0,0,l+reed_socket_len]) pipe_socket(pipe_socket_len, 16, 18);
	translate([0,0,0]) base_pipe(5, 6, 9);
	translate([0,0,horn_pos]) pipe_socket(horn_socket_len, 16, 18);
}