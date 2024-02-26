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

module pipe_plug(l, d1, d2) {
	base_pipe(l, d1, (d2-d1)/2);
	curbs(l, d2, d2*1.05, 6);
}

module pipe_horn_plug(l, d1, d2) {
	base_pipe(l, d1, (d2-d1)/2);
}

module holes_cutter(l, d, thickness, holes) {
	translate([0,holes[0][0]*l,0]) rotate([0,-20,0]) cylinder(h=d+thickness+eps, d1=d*0.7*holes[0][1], d2=d);
	for(i = [1:2]) {
		hole_loc = holes[i][0];
		translate([0,hole_loc*l,0]) cylinder(h=d+thickness+eps, d1=d*0.7*holes[i][1], d2=d*holes[i][1]);
	}
	translate([0,holes[3][0]*l,0]) rotate([0,180,0]) cylinder(h=d+thickness+eps, d1=d*0.7*holes[3][1], d2=d*holes[3][1]);
	for(i = [4:7]) {
		hole_loc = holes[i][0];
		translate([0,hole_loc*l,0]) cylinder(h=d+thickness+eps, d1=d*holes[i][1], d2=d*holes[i][1]);
	}
	translate([0,holes[8][0]*l,0]) rotate([0,180,0]) cylinder(h=d+thickness+eps, d1=d*holes[8][1], d2=d*holes[8][1]);
}

module horn(length, d_end, thickness, d_sock_in, d_sock_out, l_sock) {
	echo(str("length=",length,", d_end=",d_end," thickness=",thickness," d_sock_in=",d_sock_in," d_sock_out=",d_sock_out," l_sock=",l_sock));
	difference() {
		cylinder(h=length, d1=d_sock_out, d2=d_end);
		union() {
			translate([0,0,l_sock+eps/2]) cylinder(h=length-l_sock, d1=d_sock_out-thickness*2, d2=d_end-thickness*2);
			translate([0,0,-eps/2]) cylinder(h=length, d=d_sock_in);
		}

	}

}

module pipe(l, d, reed_d_in, thickness, holes) {
	
	difference() {
		base_pipe(l, d, thickness);
		translate([0, 0, 0]) rotate([90,0,0]) holes_cutter(l, d, thickness, holes);
	}

	reed_gap_eps = 1.4;
	translate([0,0,l]) pipe_reed_socket(reed_socket_len, d+2*thickness, 24, reed_d_in+reed_gap_eps, reed_d_in*1.2+reed_gap_eps);
	translate([0,0,l+reed_socket_len]) pipe_plug(pipe_plug_len, 15, 17);
	difference() {
		cylinder(h=d, d1=24, d2=16);
		translate([0,0,-eps/2]) cylinder(h=d+eps, d=d);
	}	
	translate([0,0,horn_pos]) pipe_plug(horn_plug_len, horn_plug_in_d, horn_plug_out_d);
}

module modular_pipe_base(l, d, reed_d_in, thickness, holes){

}