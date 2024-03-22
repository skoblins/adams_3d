module leaf_fastener_tube(h, d_in, thickness) {
	eps = 0.01;
	difference() {
		cylinder(h = h, d = d_in + 2 * thickness);
		translate([0,0,-eps / 2 ]) cylinder(h = h + eps, d = d_in);
	}
}

eps = 0.1;
flex_hole_narrowing_extra_d_for_rant = 4;
flex_hole_narrowing_clearance = 0.8;

module flex_hole_narrowing() {
	eps = 0.1;
	PLA_shrinking_remedy = 1.225;

	function calculate_h_rel(x = 0) = variants_pipe_thickness_bottom * (variants_pipe_len - x)/variants_pipe_len + x/variants_pipe_len * variants_pipe_thickness_top;

	// holes_no = len(variants_pipe_holes) - 1
	holes_no = [6,7,8];
	hole_sizes = [4,5,6,7];
	// hole_sizes = [6];

	for(i = holes_no) {
		for(j = hole_sizes) {
			echo(i, j);
			translate([j * (variants_pipe_in_d + flex_hole_narrowing_extra_d_for_rant + flex_hole_narrowing_clearance), i * (variants_pipe_in_d + flex_hole_narrowing_extra_d_for_rant + flex_hole_narrowing_clearance), 0]) {
				difference() {
					union() {
						cylinder(h=calculate_h_rel(variants_pipe_holes[i][0] * variants_pipe_len), d=variants_pipe_in_d + PLA_shrinking_remedy);
						cylinder(h=0.8, d=variants_pipe_in_d+flex_hole_narrowing_extra_d_for_rant);
					}
					translate([0,0,-eps/2]) cylinder(h=variants_pipe_in_d * 2, d = j);
				}
			}
		}
	}
}

module box_for_flex_hole_narrowing() {
	unit = (variants_pipe_in_d + flex_hole_narrowing_extra_d_for_rant + flex_hole_narrowing_clearance);
	holes_no = len(variants_pipe_holes);
	hole_sizes = [4,5,6,7];
	b_len = (holes_no + 1) * unit;
	b_wdth = 5 * unit;
	b_h = variants_pipe_in_d;
	// echo(b_len, b_wdth, b_h);
	echo(holes_no, hole_sizes);
	difference() {
		cube([b_wdth, b_len, b_h]);
		translate([unit, unit, variants_pipe_in_d * 0.5 ]) union() {
			for(i = [6, 7, 8]) {
				for(j = [0 : len(hole_sizes) - 1]) {
					translate([j * (variants_pipe_in_d + flex_hole_narrowing_extra_d_for_rant + flex_hole_narrowing_clearance), i * (variants_pipe_in_d + flex_hole_narrowing_extra_d_for_rant + flex_hole_narrowing_clearance), 0]) {
						cylinder(h = variants_pipe_in_d, d = variants_pipe_in_d + flex_hole_narrowing_extra_d_for_rant);
					}
				}
			}
		}
	}
	translate([0, 0, variants_pipe_in_d - eps/2]) {
		cube([1.6, b_len, variants_pipe_in_d + 3.2]);
		cube([b_wdth, 1.6, variants_pipe_in_d + 3.2]);
	}
	translate([b_wdth - 1.6, 0, variants_pipe_in_d - eps/2]) {
		cube([1.6, b_len, variants_pipe_in_d]);
	}
	translate([0, b_len - 1.6, variants_pipe_in_d - eps/2]) {
		cube([b_wdth, 1.6, variants_pipe_in_d + 3.2]);
	}
	// cover
	translate([0.8, 0.8, 2 * variants_pipe_in_d - eps/2]) {
		cube([b_wdth - 1.6, b_len - 1.6, 1.6]);
	}
}

module pipe_reed_socket_flex_part(l, reed_d1, reed_d2, pipe_plug_in_d) {
	intersection() {
		difference(){
			cylinder(h=l, d1=pipe_plug_in_d, d2=pipe_plug_in_d);
			#translate([0,0,-eps/2]) cylinder(h=l+eps, d1=reed_d1, d2=reed_d2);
		}
		union() {
			cylinder(h=l, d=reed_d2+1.4);
			cylinder(h=2, d1=pipe_plug_in_d-0.8, d2=pipe_plug_in_d);
		}
	}
	translate([0,0,2-eps/2])
		difference() {
			cylinder(h = pipe_plug_len * 0.66, d1 = pipe_plug_in_d, d2 = pipe_plug_in_d + 0.1);
			translate([0,0,-eps / 2]) cylinder(h = pipe_plug_len - 2 + eps, d = pipe_plug_in_d - 0.8);
		}
}

module pipe_reed_socket_flex_part_replacement_tool() {
	difference() {
		translate([0,0,-eps/2]) difference() {
			cylinder(h = 2 * pipe_plug_len, d = pipe_plug_in_d - 1.2);
			translate([0,0,-eps / 2])
				cylinder(h = 1.8 * pipe_plug_len, d = pipe_plug_in_d - 1.2 - 1.2);
		}
		translate([-pipe_plug_in_d/2, -pipe_plug_in_d/4, -eps])
			cube([pipe_plug_in_d, pipe_plug_in_d / 2, 1.8 * pipe_plug_len]);
	}
	cylinder(h = 1.8 * pipe_plug_len + eps, d = reed_d1 - 0.4);
}

module just_a_box(h, l, w, wall_thickness) {
	clearance = 0.4;
	union() {
		cube([l - wall_thickness - clearance, w, wall_thickness]);
		cube([l + wall_thickness + clearance, wall_thickness, h]);
		translate([0, w - wall_thickness, 0]) cube([l + wall_thickness + clearance, wall_thickness, h]);
		translate([0, 0, h - wall_thickness]) cube([l + wall_thickness + clearance, w, wall_thickness]);
		cube([wall_thickness, w, h]);
		translate([l + clearance, 0 , 0]) cube([wall_thickness, wall_thickness * 3, h]);
		translate([l + clearance, w - 3 * wall_thickness , 0]) cube([wall_thickness, wall_thickness * 3, h]);
	}

	%translate([l - wall_thickness, wall_thickness + clearance, - clearance])
		cube([wall_thickness, w - 2 * wall_thickness - clearance, h - wall_thickness - clearance]);

}

module flex_part_in_just_a_box(h, l, w, wall_thickness) {
	clearance = 0.4;
	union() {
		// 4 main walls
		translate([wall_thickness + clearance, wall_thickness + clearance, -wall_thickness + 2 * 0.8 + clearance]) cube([l - 2 * (wall_thickness  + clearance), 0.8, h - 2 * clearance - 0.8]);
		translate([wall_thickness + clearance, w - wall_thickness - 0.8 - clearance, -wall_thickness + 2 * 0.8 + clearance]) cube([l - 2 * (wall_thickness  + clearance), 0.8, h - 2 * clearance - 0.8]);
		translate([wall_thickness + clearance, wall_thickness + 0.8 + clearance, h - wall_thickness - clearance]) cube([l - 2* (wall_thickness + clearance), w - 2 * (wall_thickness + 0.8 + clearance), 0.8]);
		translate([wall_thickness + clearance, wall_thickness + clearance, 0]) cube([0.8, w - 2 * (wall_thickness + clearance), h - 2 * clearance - 0.8]);
		// inside walls - horizontal
		for(i = [1 : 34]) {
			translate([0, 0, h - (22 + 2.5 * i + i * i / 18)])
				rotate([0, -45, 0])
				translate([wall_thickness, 0, -h + wall_thickness + clearance])
					translate([wall_thickness + clearance, wall_thickness + 0.8 + clearance, h - wall_thickness - clearance])
						cube([(l - 2* (wall_thickness + clearance))/2, w - 2 * (wall_thickness + 0.8), 0.8]);
		}
		// inside walls - vertical
		for(i = [1 : 9]){
			translate([wall_thickness + clearance, wall_thickness + 0.8 + 6 * i + i * i / 3, 0])
				cube([(l - 2* (wall_thickness + clearance))/2 * sin(45), 0.8, h - wall_thickness]);
		}
	}
}
