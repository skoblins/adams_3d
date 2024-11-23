include <linear_bearing-2.0.scad>
include <posfix_crossbar_snap.scad>
include <crossbar.scad>

$fn=25;

// general
_clearance = 0.4;
_eps = 0.1;

// pipe bearing
pipe_bearing_outer_diameter = 35;
pipe_bearing_inner_diameter = 25;


// rail
posfix_rail_length = 100;
posfix_rail_width = 30;
posfix_rail_height = 10;
posfix_rail_tooth_length = 2;
posfix_tooth_height_coeff = 0.66;
posfix_connector_length = 25;
entire_rail_length_relative_to_pipe_center = 2*posfix_rail_length + 3*posfix_connector_length + pipe_bearing_outer_diameter;

// snap
posfix_snap_length = 35;
posfix_snap_width = posfix_rail_width * 1.5;
posfix_snap_height = posfix_rail_height * 1.5;
posfix_center_connector_length = 40;

// crossbar
crossbar_middle_part_length = entire_rail_length_relative_to_pipe_center - 2*posfix_center_connector_length - posfix_snap_width - _clearance;

// linear_bearings(selection=1, h=10, dInner=25, dOuter=35, dInnerLoose=26);
// linear_bearings(selection=2, h=10, dInner=25, dOuter=35, dInnerLoose=26);

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

// posfix_crossbar_snap_right_upper(
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

// posfix_crossbar_rail_with_connector(length = posfix_rail_length, width = posfix_rail_width,
//     height = posfix_rail_height, tooth_length = posfix_rail_tooth_length,
//     tooth_height_coeff = posfix_tooth_height_coeff, connector_length = posfix_connector_length,
//     nut_height = 8, nut_width = 3, screw_d = 5, screw_head_h = 5, screw_head_d = 8.5,
//     clearance = _clearance
// );

// posfix_crossbar_rail_right_with_connector(length = posfix_rail_length, width = posfix_rail_width,
//     height = posfix_rail_height, tooth_length = posfix_rail_tooth_length,
//     tooth_height_coeff = posfix_tooth_height_coeff, connector_length = posfix_connector_length,
//     nut_height = 8, nut_width = 3, screw_d = 5, screw_head_h = 5, screw_head_d = 8.5,
//     clearance = _clearance
// );

// crossbar(connector_length = posfix_center_connector_length, width = posfix_snap_length,
//     middle_part_length = crossbar_middle_part_length, height = posfix_rail_height);