eps = 0.02;

module base_pipe(l, d, thickness_bottom, thickness_top) {
	echo(str(thickness_bottom, ", ", thickness_top));
	difference() {
		cylinder(h=l, d1=d+thickness_bottom*2, d2=d+thickness_top*2);
		translate([0,0,-l*0.01]) cylinder(h=l*1.1, d=d);
	}
}

module pipe_reed_socket_flex_part(l, d1, d2, reed_d1, reed_d2, pipe_plug_in_d) {
	intersection() {
		difference(){
			cylinder(h=l, d1=pipe_plug_in_d, d2=pipe_plug_in_d);
			translate([0,0,-eps/2]) cylinder(h=l+eps, d1=reed_d1, d2=reed_d2);
		}
		union() {
			cylinder(h=l, d=reed_d2+1);
			cylinder(h=2, d1=pipe_plug_in_d-0.8, d2=pipe_plug_in_d);
		}
	}
	translate([0,0,2-eps/2]) difference() {
		cylinder(h=pipe_plug_len-2, d1=pipe_plug_in_d, d2=pipe_plug_in_d+0.1);
		translate([0,0,-eps/2]) cylinder(h=pipe_plug_len-2+eps, d=pipe_plug_in_d-0.8);
	}
}

module pipe_reed_socket_hard_part(l, d1, d2, reed_d1, reed_d2, pipe_plug_in_d) {
	difference() {
		cylinder(h=l, d1=d1, d2=d2);
		translate([0,0,-eps/2]) cylinder(h=l+eps, d=pipe_plug_in_d);
	}
}

module pipe_reed_socket(l, d1, d2, reed_d1, reed_d2, pipe_plug_in_d) {
	// params are local dimensions, not of the entire pipe!
	assert(pipe_plug_in_d < d1, "The bottom diameter of the pipe reed socket is smaller than the plug inside diameter!)");
	pipe_reed_socket_hard_part(l, d1, d2, reed_d1, reed_d2, pipe_plug_in_d);
	%pipe_reed_socket_flex_part(l, d1, d2, reed_d1, reed_d2, pipe_plug_in_d);
}


module curbs(l, d1, d2, flute_count) {
	for(i=[1:flute_count]) {
        translate([0,0,(i-1)*l/flute_count]){
            difference(){
            	cylinder(h=l/flute_count/2, d1=d1, d2=d2);
            	translate([0,0,-eps]) cylinder(h=l+eps, d=d1);
            }
        }
    }
}

module pipe_plug(l, d1, d2) {
	base_pipe(l, d1, (d2-d1)/2, (d2-d1)/2);
	curbs(l, d2, d2*1.05, 6);
}

module pipe_horn_plug(l, d1, d2) {
	base_pipe(l, d1, (d2-d1)/2, (d2-d1)/2);
}

module holes_cutter(l, d, thickness, holes) {
	// holes_broadening_coeff = 0.7; // looks good, but... not suitable for my wood working tools.
	holes_broadening_coeff = 1;
	translate([0,holes[0][0]*l,0]) rotate([0,-20,0]) cylinder(h=d+thickness+eps, d1=d*holes_broadening_coeff*holes[0][1], d2=d);
	for(i = [1:2]) {
		hole_loc = holes[i][0];
		translate([0,hole_loc*l,0]) cylinder(h=d+thickness+eps, d1=d*holes_broadening_coeff*holes[i][1], d2=d*holes[i][1]);
	}
	translate([0,holes[3][0]*l,0]) rotate([0,180,0]) cylinder(h=d+thickness+eps, d1=d*holes_broadening_coeff*holes[3][1], d2=d*holes[3][1]);
	for(i = [4:7]) {
		hole_loc = holes[i][0];
		translate([0,hole_loc*l,0]) cylinder(h=d+thickness+eps, d1=d*holes[i][1], d2=d*holes[i][1]);
	}
	translate([0,holes[8][0]*l,0]) rotate([0,180,0]) cylinder(h=d+thickness+eps, d1=d*holes[8][1], d2=d*holes[8][1]);
}

module horn(length, d_end, thickness, d_sock_in, d_sock_out, l_sock) {
	echo(str("length=",length,", d_end=",d_end," thickness=",thickness," d_sock_in=",d_sock_in," d_sock_out=",d_sock_out," l_sock=",l_sock));
	// difference() {
	// 	cylinder(h=length, d1=d_sock_out, d2=d_end);
	// 	union() {
	// 		translate([0,0,l_sock+eps/2]) cylinder(h=length-l_sock, d1=d_sock_out-thickness*2, d2=d_end-thickness*2);
	// 		translate([0,0,-eps/2]) cylinder(h=length, d=d_sock_in);
	// 	}

	// }
	linear_extrude(height = length, center = true, convexity = 10, scale=[1.5,1.7], twist=120, $fn=100)
	 translate([10, 0, 0])
	 circle(r = d_sock_out);

}

module pipe(l, d_in, reed_d_in, thickness_bottom, thickness_top, holes) {
	echo(str(thickness_bottom, ", ", thickness_top));
	// pipe
	difference() {
		base_pipe(l, d_in, thickness_bottom, thickness_top);
		translate([0, 0, 0]) rotate([90,0,0]) holes_cutter(l, d_in, thickness_bottom, holes);
	}

	reed_gap_eps = 1.4;

	// reed socket
	translate([0,0,l]) pipe_reed_socket(reed_socket_len, d_in+2*thickness_top, 24, reed_d_in+reed_gap_eps, reed_d_in*1.1+reed_gap_eps, variants_pipe_plug_in_d);

	// pipe plug (to the bag)
	translate([0,0,l+reed_socket_len]) pipe_plug(pipe_plug_len, variants_pipe_plug_in_d, 17);

	// // ornament before the pipe plug (to the horn)
	// difference() {
	// 	cylinder(h=d_in, d1=24, d2=16);
	// 	translate([0,0,-eps/2]) cylinder(h=d_in+eps, d=d_in);
	// }	

	// pipe plug (to the horn)
	translate([0,0,horn_pos]) pipe_plug(horn_plug_len, d_in, horn_plug_out_d);
}

module modular_pipe_base(l, d, reed_d_in, thickness, holes){

}
