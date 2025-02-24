include <linear_bearing-2.0.scad>
include <posfix_crossbar_snap.scad>
include <crossbar.scad>
include <base_plate.scad>
include <top_mount.scad>

$align_msg=false;

// general
_clearance = 0.4;
_eps = 0.1;

// pipe bearing
pipe_bearing_outer_diameter = 35;
pipe_bearing_inner_diameter = 25;


// rail
posfix_rail_length = 100;
posfix_rail_width = 30;
posfix_rail_height = 15.4;
// posfix_rail_height = 20;
posfix_rail_tooth_length = 2;
posfix_tooth_height_coeff = 5/6;
posfix_connector_length = 25;
entire_rail_length_relative_to_pipe_center = 2*posfix_rail_length + 3*posfix_connector_length + pipe_bearing_outer_diameter;
echo("entire_rail_length_relative_to_pipe_center: ", entire_rail_length_relative_to_pipe_center);

// snap
posfix_snap_length = 35;
posfix_snap_width = posfix_rail_width * 1.5;
posfix_snap_height = posfix_rail_height * 1.5;
posfix_center_connector_length = 40;

// crossbar
crossbar_middle_part_length = entire_rail_length_relative_to_pipe_center - 2*posfix_center_connector_length - posfix_snap_width - _clearance;

// base plate
base_plate_pipe_hose_out_d = pipe_bearing_outer_diameter * 3/2; // the bottom must be stronger
base_zipper_width = (entire_rail_length_relative_to_pipe_center + base_plate_pipe_hose_out_d)/2 * 1/8;
echo("base_zipper_width: ", base_zipper_width);
base_plate_part_length = (entire_rail_length_relative_to_pipe_center + base_plate_pipe_hose_out_d - base_zipper_width)/2;
echo("base_plate_part_length: ", base_plate_part_length);
sumup = 2*base_plate_part_length - base_plate_pipe_hose_out_d + base_zipper_width;
echo("summed up: ", sumup);
assert(sumup == entire_rail_length_relative_to_pipe_center, "It all must fit together");
base_zipper_length = base_plate_part_length/2;
base_plate_height = 25; // this is limited by the height/length of the screws/bolts etc.
pipe_hose_height = 2*base_plate_height;
claw_height = pipe_hose_height-base_plate_height/2;

// Crossbar
// right(35/2) up(100) {
//     fwd(247.375) right(40) xrot(90) zrot(180) linear_bearings(selection=1, h=10, dInner=25, dOuter=35, dInnerLoose=26);
//     right(85) fwd(156.25) zrot(-90) posfix_crossbar_rail_with_connector(length = posfix_rail_length, width = posfix_rail_width,
//         height = posfix_rail_height, tooth_length = posfix_rail_tooth_length,
//         tooth_height_coeff = posfix_tooth_height_coeff, connector_length = posfix_connector_length,
//         nut_height = 8, nut_width = 3, screw_d = 5, screw_head_h = 5, screw_head_d = 8.5,
//         clearance = _clearance
//     );
//     fwd(28.7) right(46) zrot(90) posfix_crossbar_rail_right_with_connector(length = posfix_rail_length, width = posfix_rail_width,
//         height = posfix_rail_height, tooth_length = posfix_rail_tooth_length,
//         tooth_height_coeff = posfix_tooth_height_coeff, connector_length = posfix_connector_length,
//         nut_height = 8, nut_width = 3, screw_d = 5, screw_head_h = 5, screw_head_d = 8.5,
//         clearance = _clearance
//     );
    // back(62.5) right(41) yrot(180) xrot(-90) linear_bearings(selection=2, h=posfix_rail_height, dInner=25.5, dOuter=35, dInnerLoose=26);
// }

// posfix_crossbar_snap_upper(
//         center_connector_length = posfix_center_connector_length,
//         snap_length = posfix_snap_length,
//         snap_width = posfix_snap_width,
//         snap_height = posfix_snap_height,
//         rail_length = posfix_rail_length,
//         rail_width = posfix_rail_width,
//         rail_height = posfix_rail_height,
//         rail_tooth_length = posfix_rail_tooth_length,
//         tooth_height_coeff = posfix_tooth_height_coeff,
//         clearance = _clearance,
//         eps = _eps
// );

// right(150) posfix_crossbar_snap_right_upper(
//     center_connector_length = posfix_center_connector_length,
//     snap_length = posfix_snap_length,
//     snap_width = posfix_snap_width,
//     snap_height = posfix_snap_height,
//     rail_length = posfix_rail_length,
//     rail_width = posfix_rail_width,
//     rail_height = posfix_rail_height,
//     rail_tooth_length = posfix_rail_tooth_length,
//     tooth_height_coeff = posfix_tooth_height_coeff,
//     clearance = _clearance,
//     eps = _eps
// );

// posfix_crossbar_snap_bottom(
//         center_connector_length = posfix_center_connector_length,
//         snap_length = posfix_snap_length,
//         snap_width = posfix_snap_width,
//         snap_height = posfix_snap_height,
//         rail_length = posfix_rail_length,
//         rail_width = posfix_rail_width,
//         rail_height = posfix_rail_height,
//         rail_tooth_length = posfix_rail_tooth_length,
//         tooth_height_coeff = posfix_tooth_height_coeff,
//         clearance = _clearance,
//         eps = _eps
// );

// posfix_crossbar_rail_right_with_connector(length = posfix_rail_length, width = posfix_rail_width,
//     height = posfix_rail_height, tooth_length = posfix_rail_tooth_length,
//     tooth_height_coeff = posfix_tooth_height_coeff, connector_length = posfix_connector_length,
//     nut_height = 8.5, nut_width = 3.5, screw_d = 5.5, screw_head_h = 5, screw_head_d = 8.5,
//     clearance = _clearance
// );

posfix_crossbar_rail_with_connector(length = posfix_rail_length, width = posfix_rail_width,
    height = posfix_rail_height, tooth_length = posfix_rail_tooth_length,
    tooth_height_coeff = posfix_tooth_height_coeff, connector_length = posfix_connector_length,
    nut_height = 8.5, nut_width = 3.5, screw_d = 5.5, screw_head_h = 5, screw_head_d = 8.5,
    clearance = _clearance
);

// crossbar(connector_length = posfix_center_connector_length, width = posfix_snap_length,
//     middle_part_length = crossbar_middle_part_length, height = posfix_snap_height);

// Bottom plate

// {
//     $fn=150;
//     additional_distance_for_presentation = 50; // set to zero for the real thing

//     base_plate_part1(base_plate_part_length, base_plate_height, base_zipper_length, base_zipper_width, pipe_hose_height);

//     left(base_plate_part_length+base_zipper_width+additional_distance_for_presentation)
//         zrot(90)
//             base_plate_part2(base_plate_part_length, base_plate_height, base_zipper_length, base_zipper_width, pipe_hose_height);

//     fwd(base_plate_part_length+base_zipper_width+additional_distance_for_presentation)
//         left(base_plate_part_length+base_zipper_width+additional_distance_for_presentation)
//             zrot(180)
//                 base_plate_part1(base_plate_part_length, base_plate_height, base_zipper_length, base_zipper_width, pipe_hose_height);

//     fwd(base_plate_part_length+base_zipper_width+additional_distance_for_presentation)
//         zrot(270)
//             base_plate_part2(base_plate_part_length, base_plate_height, base_zipper_length, base_zipper_width, pipe_hose_height);
// }

// Top plate
// top_plate_height = 50;
// top_mount(pipe_bearing_outer_diameter, pipe_bearing_inner_diameter, top_plate_height, entire_rail_length_relative_to_pipe_center);