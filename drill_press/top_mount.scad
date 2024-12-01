include <BOSL2/std.scad>

module top_mount(pipe_bearing_outer_diameter, pipe_bearing_inner_diameter, mount_h, side_pipe_center_relative_l){
    $fn=200;
    tube(od=pipe_bearing_outer_diameter, id=pipe_bearing_inner_diameter + 1, h=mount_h){
        align(TOP, inside=true) zcyl(d=pipe_bearing_outer_diameter, h=5);
        align(FRONT+LEFT) fillet(d=pipe_bearing_outer_diameter, h=mount_h);
        align(FRONT+RIGHT) fillet(spin=90, d=pipe_bearing_outer_diameter, h=mount_h);
        fwd(pipe_bearing_outer_diameter) segment_compliment_with_bolts(length = pipe_bearing_outer_diameter, height = mount_h, width = 20/*because of screw len*/, screw_head_h = 5, screw_head_d = 8.5, screw_d = 5, nut_height = 8, nut_width = 3, clearance = _clearance, anchor = CENTER, spin = 90, orient = UP)
        back(20) segment_with_square_nuts(length = pipe_bearing_outer_diameter, height = mount_h, width = 20/*because of screw len*/, screw_head_h = 5, screw_head_d = 8.5, screw_d = 5, nut_height = 8, nut_width = 3, clearance = _clearance, spin=180)
        align(RIGHT) cuboid([side_pipe_center_relative_l-3*pipe_bearing_outer_diameter,20,mount_h])
        align(RIGHT)segment_with_square_nuts(length = pipe_bearing_outer_diameter, height = mount_h, width = 20/*because of screw len*/, screw_head_h = 5, screw_head_d = 8.5, screw_d = 5, nut_height = 8, nut_width = 3, clearance = _clearance, spin=0);
    }


    up(100) tube(od=pipe_bearing_outer_diameter, id=pipe_bearing_inner_diameter + 1, h=mount_h){
        align(TOP, inside=true) zcyl(d=pipe_bearing_outer_diameter, h=5);
        align(FRONT+LEFT) fillet(d=pipe_bearing_outer_diameter, h=mount_h);
        align(FRONT+RIGHT) fillet(spin=90, d=pipe_bearing_outer_diameter, h=mount_h);
        fwd(pipe_bearing_outer_diameter) segment_compliment_with_bolts(length = pipe_bearing_outer_diameter, height = mount_h, width = 20/*because of screw len*/, screw_head_h = 5, screw_head_d = 8.5, screw_d = 5, nut_height = 8, nut_width = 3, clearance = _clearance, anchor = CENTER, spin = -90, orient = UP);
    }

    up(200) tube(od=pipe_bearing_outer_diameter, id=pipe_bearing_inner_diameter + 1, h=mount_h){
        align(TOP, inside=true) zcyl(d=pipe_bearing_outer_diameter, h=5);
        align(FRONT+LEFT) fillet(d=pipe_bearing_outer_diameter, h=mount_h);
        align(FRONT+RIGHT) fillet(spin=90, d=pipe_bearing_outer_diameter, h=mount_h);
        align(BACK+RIGHT) fillet(spin=180, d=pipe_bearing_outer_diameter, h=mount_h);
        fwd(pipe_bearing_outer_diameter) segment_compliment_with_bolts(length = pipe_bearing_outer_diameter, height = mount_h, width = 20/*because of screw len*/, screw_head_h = 5, screw_head_d = 8.5, screw_d = 5, nut_height = 8, nut_width = 3, clearance = _clearance, anchor = CENTER, spin = -90, orient = UP);
        right(pipe_bearing_outer_diameter) segment_compliment_with_bolts(length = pipe_bearing_outer_diameter, height = mount_h, width = 20/*because of screw len*/, screw_head_h = 5, screw_head_d = 8.5, screw_d = 5, nut_height = 8, nut_width = 3, clearance = _clearance, anchor = CENTER, spin = 180, orient = UP);
    }
}