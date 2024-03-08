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
			for(i = [0 : holes_no - 1]) {
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
	!translate([0.8, 0.8, 2 * variants_pipe_in_d - eps/2]) {
		cube([b_wdth - 1.6, b_len - 1.6, 1.6]);
	}
}
