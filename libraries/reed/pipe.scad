include <basic_shapes.scad>

eps = 0.02;


module pipe_reed_socket_hard_part(l, d1, d2, reed_d1, reed_d2, pipe_plug_in_d) {
	difference() {
		cylinder(h=l, d1=d1, d2=d2);
		translate([0,0,-eps/2]) cylinder(h=l+eps, d=pipe_plug_in_d);
	}
}

module pipe_reed_socket(l, d1, d2, reed_d1, reed_d2, pipe_plug_in_d) {
	left_space = variants_pipe_len * (1 - variants_pipe_holes[8][0]) - variants_reed_pipe_in_diameter * variants_pipe_holes[8][1];
	translate([0, 0, -left_space]) pipe_reed_socket_hard_part(l + left_space, d1, d2, reed_d1, reed_d2, pipe_plug_in_d);
	// pipe_reed_socket_flex_part(l, d1, d2, reed_d1, reed_d2, pipe_plug_in_d);
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
	// echo(l = l, d = d, thickness = thickness, holes = holes);
	// holes_broadening_coeff = 0.7; // looks good, but... not suitable for my wood working tools.
	holes_broadening_coeff = 1;
	echo(holes[0][0]*l);
	translate([0,holes[0][0]*l,0]) rotate([0,-20,0]) cylinder(h=d+thickness+eps, d1=d*holes_broadening_coeff*holes[0][1], d2=d*holes[0][1]);
	for(i = [1:2]) {
		hole_loc = holes[i][0];
		echo(hole_loc*l);
		translate([0,hole_loc*l,0]) cylinder(h=d+thickness+eps, d1=d*holes_broadening_coeff*holes[i][1], d2=d*holes[i][1]);
	}
	echo(holes[3][0]*l);
	translate([0,holes[3][0]*l,0]) rotate([0,180,0]) cylinder(h=d+thickness+eps, d1=d*holes_broadening_coeff*holes[3][1], d2=d*holes[3][1]);
	for(i = [4:7]) {
		echo(hole_loc*l);
		hole_loc = holes[i][0];
		translate([0,hole_loc*l,0]) cylinder(h=d+thickness+eps, d1=d*holes[i][1], d2=d*holes[i][1]);
	}
	echo(holes[8][0]*l);
	translate([0,holes[8][0]*l,0]) rotate([0,180,0]) cylinder(h=d+thickness+eps, d1=d*holes[8][1], d2=d*holes[8][1]);
}

module horn() {
	eps = 0.1;
	unit = 2;
	grow_coeff = 1.25;

	function diameter(z)    = variants_pipe_bottom_d + grow_coeff * z / horn_len * variants_pipe_bottom_d;
	function in_diameter(z) = ((horn_len - z) / horn_len) * horn_plug_out_d + z / horn_len * diameter(z) * 0.95;
	function rotation(z) = z / horn_len * 90;
	function scale_x(z) = 1 + 0.15 * z / horn_len;
	function scale_y(z) = 1 - 0.15 * z / horn_len;
	function big_rotation(z) = z / horn_len * 100;

	difference() {
		for(z = [0 : unit : horn_len - unit]) {
			hull() {
				rotate([big_rotation(z), 0, rotation(z)])  translate([0, sin(big_rotation(z)) * z, z]) scale([scale_x(z), scale_y(z)]) cylinder(h=1, d = diameter(z), center = true);
				rotate([big_rotation(z + unit), 0, rotation(z + unit)])  translate([0, sin(big_rotation(z + unit)) * (z + unit), z + unit]) scale([scale_x(z  + unit), scale_y(z + unit)]) cylinder(h=1, d = diameter(z + unit), center = true);
			}
		}
		for(z = [0 : unit : horn_len - unit]) {
			hull() {
				rotate([big_rotation(z), 0, rotation(z)])  translate([-eps / 2, sin(big_rotation(z)) * z, z]) scale([scale_x(z), scale_y(z)]) cylinder(h = 1 + eps, d = in_diameter(z), center = true);
				rotate([big_rotation(z + unit), 0, rotation(z + unit)])  translate([-eps / 2, sin(big_rotation(z + unit)) * (z + unit), z + unit]) scale([scale_x(z  + unit), scale_y(z + unit)]) cylinder(h = 1 + eps, d = in_diameter(z + unit), center = true);
			}
		}
	}
}

module pipe(l, d_in, reed_d_in, thickness_bottom, thickness_top, holes) {
	echo(str("length = ", l, ", thickness bottom = ", thickness_bottom, ", thickness top = ", thickness_top));
	// pipe
	difference() {
		base_pipe(l, d_in, thickness_bottom, thickness_top);
		rotate([90,0,0]) holes_cutter(l, d_in, thickness_bottom, holes);
	}

	reed_gap_eps = 1.4;

	// reed socket
	translate([0,0,l]) pipe_reed_socket(reed_socket_len, d_in+2*thickness_top, variants_pipe_plug_stopper_d, reed_d_in+reed_gap_eps, reed_d_in*1.1+reed_gap_eps, variants_pipe_plug_in_d);

	// pipe plug (to the bag)
	translate([0,0,l+reed_socket_len]) pipe_plug(pipe_plug_len, variants_pipe_plug_in_d, variants_pipe_plug_out_d);

	// // ornament before the pipe plug (to the horn)
	// difference() {
	// 	cylinder(h=d_in, d1=24, d2=16);
	// 	translate([0,0,-eps/2]) cylinder(h=d_in+eps, d=d_in);
	// }	

	// pipe plug (to the horn)
	translate([0,0,horn_pos]) pipe_plug(horn_plug_len, d_in, horn_plug_out_d);
}

module support_struct() {
	entire_support_h = variants_pipe_len * 0.66;
	support_point_start = 0;
	support_point_distance = entire_support_h/4;
	support_xy_clearance = 3.2;
	support_touch_eps = 0.4;

	function calculate_abs_support_horiz_extent(y) = (y - horn_plug_len)/(entire_support_h + horn_plug_len) * (variants_pipe_thickness_bottom - variants_pipe_thickness_top) + support_xy_clearance + support_touch_eps;

	translate([variants_pipe_thickness_bottom+variants_pipe_in_d/2 + support_xy_clearance, 0, -horn_plug_len])
		rotate([90,0,0])
			linear_extrude(height=0.4)
				polygon(
					points=[
						[0,0],
						[entire_support_h/2,0],
						[-calculate_abs_support_horiz_extent(entire_support_h-horn_plug_len), entire_support_h+horn_plug_len],
						[0,(entire_support_h+horn_plug_len)*0.75],
						[-calculate_abs_support_horiz_extent((entire_support_h-horn_plug_len)*0.75), (entire_support_h+horn_plug_len)*0.75],
						[0,(entire_support_h+horn_plug_len)/2],
						[-calculate_abs_support_horiz_extent((entire_support_h-horn_plug_len)/2), (entire_support_h+horn_plug_len)/2],
						[0, (entire_support_h+horn_plug_len)/3],
						[-calculate_abs_support_horiz_extent((entire_support_h-horn_plug_len)/4), (entire_support_h+horn_plug_len)/4],
						[0, horn_plug_len],
						[0,0]
					]);
}
