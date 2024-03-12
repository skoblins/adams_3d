include <reed/rings_tubes_etc.scad>
include <variants-reed-pipe.scad>
include <variants-pipe.scad>

$fn = 100;

leaf_fastener_tube( variants_reed_pipe_fastener_length,
	(variants_reed_pipe_in_diameter + 2 * variants_reed_pipe_wall_thickness) * 0.9, // 0.9 to provide some force.
	0.8
);

// box_for_flex_hole_narrowing();
