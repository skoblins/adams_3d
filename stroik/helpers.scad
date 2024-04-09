include <reed/rings_tubes_etc.scad>
include <variants-pipe.scad>
// include <variants-reed-burdon.scad>
include <variants-reed-pipe.scad>
include <reed/tools.scad>

$fn = 100;

arrange(spacing = 40, n = 3) {

	// leaf_fastener_tube( variants_reed_pipe_fastener_length - 0.8,
	// 	(variants_reed_pipe_in_diameter + 2 * variants_reed_pipe_wall_thickness),
	// 	0.6
	// );

	// leaf_fastener_tube( variants_reed_pipe_fastener_length - 0.8,
	// 	(variants_reed_pipe_in_diameter + 2 * variants_reed_pipe_wall_thickness),
	// 	0.6
	// );

	// // box_for_flex_hole_narrowing();

	// reed_gap_eps = 0.6;

	// pipe_reed_socket_flex_part(
	// 	l = reed_socket_len,
	// 	reed_d1 = variants_reed_pipe_in_diameter + reed_gap_eps,
	// 	reed_d2 = 1.4 * variants_reed_pipe_in_diameter + reed_gap_eps,
	// 	pipe_plug_in_d = variants_pipe_plug_in_d
	// );

	// color(alpha = 0.2) just_a_box(h = 170, l = 40, w = 100, wall_thickness = 2);
	// flex_part_in_just_a_box(h = 170, l = 40, w = 100, wall_thickness = 2);
	box_for_leafs(h = 170, l = 40, w = 100, wall_thickness = 2);

	// translate([60, 0, 0]) pipe_reed_socket_flex_part_replacement_tool(
	// 	l = reed_socket_len,
	// 	reed_d1 = variants_reed_pipe_in_diameter + reed_gap_eps,
	// 	reed_d2 = variants_reed_pipe_in_diameter * 1.1 + reed_gap_eps,
	// 	pipe_plug_in_d = variants_pipe_plug_in_d
	// );


}

