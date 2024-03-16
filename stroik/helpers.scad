include <reed/rings_tubes_etc.scad>
include <variants-pipe.scad>
// include <variants-reed-burdon.scad>
include <variants-reed-pipe.scad>

$fn = 100;

// leaf_fastener_tube( variants_reed_pipe_fastener_length - 0.8,
// 	(variants_reed_pipe_in_diameter + 2 * variants_reed_pipe_wall_thickness) * 0.9,
// 	0.4
// );

// box_for_flex_hole_narrowing();

reed_gap_eps = 1.4;

// reed_socket_len, d_in+2*thickness_top, variants_pipe_plug_stopper_d, reed_d_in+reed_gap_eps, reed_d_in*1.1+reed_gap_eps, variants_pipe_plug_in_d

// translate([20, 0, 0]) pipe_reed_socket_flex_part(
// 	l = reed_socket_len,
// 	d1 = 0,
// 	d2 = 0,
// 	reed_d1 = variants_reed_pipe_in_diameter + reed_gap_eps,
// 	reed_d2 = variants_reed_pipe_in_diameter * 1.1 + reed_gap_eps,
// 	pipe_plug_in_d = variants_pipe_plug_in_d
// );

just_a_box(h = 170, l = 40, w = 100, wall_thickness = 2);
