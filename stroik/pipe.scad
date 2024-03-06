include <reed/pipe.scad>
include <variants-pipe.scad>
include <variants-reed-pipe.scad>

$fn=100;

%pipe(l=variants_pipe_len, d_in=variants_pipe_in_d, reed_d_in=variants_reed_pipe_in_diameter, thickness_bottom=variants_pipe_thickness_bottom, thickness_top=variants_pipe_thickness_top, holes=[[0.1, 4/8], [0.23, 8/8], [0.37, 5/8], [0.44, 6/8], [0.52, 7/8], [0.66, 6/8], [0.78, 5/8], [0.89, 5/8], [0.97, 5/8]]);


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


support_struct();
rotate([0,0,90]) support_struct();
rotate([0,0,180]) support_struct();
rotate([0,0,270]) support_struct();