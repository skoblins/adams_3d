include <reed/pipe.scad>
include <variants-reed-burdon.scad>

$fn = 100;

variants_burdon_segment_l = 210;
variants_burdon_d_out = 24;
variants_burdon_d_in = 8;

// Arrange its children in a regular rectangular array
 //      spacing - the space between children origins
 //      n       - the number of children along x axis
 module arrange(spacing=50, n=5) {
    nparts = $children;
    for(i=[0:1:n-1], j=[0:nparts/n])
        if (i+n*j < nparts)
            translate([spacing*(i+1), spacing*j, 0])
                children(i+n*j);
 }

module burdon_socket(l = 40, d_in = 19, d_out = 28) {
    thickness = (d_out - d_in) / 2;
    base_pipe(l = l, d = d_in, thickness_bottom = thickness, thickness_top = thickness);
}

module burdon_plug(l = 40, d_in = 8, d_out = 17) {
    thickness = (d_out - d_in) / 2;
    base_pipe(l = l, d = d_in, thickness_bottom = thickness, thickness_top = thickness);
    curbs(l, d_out, d_out+0.8, 6);
}

module burdon_pipe_segment(lengths) {
    for (i = [0: $children - 1]) {
        translate([0, 0, lengths[i]])
            children(i);
    }
}

module support_struct() {
    entire_support_h = variants_burdon_segment_l * 0.66;
    support_point_start = 40;
    support_width = entire_support_h/6;
    support_xy_clearance = 6.4;
    support_touch_eps = 0.5;
    horn_plug_len = 40;

    translate([variants_burdon_d_out / 2 + support_xy_clearance, 0, -horn_plug_len])
        rotate([90, 0, 0])
            linear_extrude(height = 0.8)
                polygon(
                    points = [
                        [0, 0],
                        [support_width, 0],
                        [2, entire_support_h + horn_plug_len],
                        [-support_xy_clearance - support_touch_eps, entire_support_h + horn_plug_len],
                        [0, (entire_support_h + horn_plug_len) * 0.75],
                        [-support_xy_clearance - support_touch_eps, (entire_support_h + horn_plug_len) * 0.75],
                        [0,(entire_support_h + horn_plug_len)/2],
                        [-support_xy_clearance - support_touch_eps, (entire_support_h + horn_plug_len) / 2],
                        // [0, (entire_support_h + horn_plug_len)/3],
                        [0, horn_plug_len],
                        [-support_xy_clearance - support_touch_eps, horn_plug_len + 1],
                        [0, 0]
                    ]);
}

arrange(spacing = 150, n = 3) {

    // first part
    burdon_pipe_segment(lengths = [0, 40, variants_burdon_segment_l - 40, 40]) {
        burdon_plug(l = 40, d_in = 13, d_out = 17);
        base_pipe(l = variants_burdon_segment_l - 80, d = variants_burdon_d_in, thickness_bottom = 8, thickness_top = 8);
        burdon_socket(l = 40, d_in = 19, d_out = variants_burdon_d_out);
        for (i=[0, 90, 180, 270]) rotate([0, 0, i]) support_struct();
    }

    // second part
    burdon_pipe_segment(lengths = [0, 40, variants_burdon_segment_l - 20, 20]) {
        burdon_plug(l = 40, d_in = variants_burdon_d_in, d_out = 17);
        base_pipe(l = variants_burdon_segment_l - 60, d = variants_burdon_d_in, thickness_bottom = 8, thickness_top = 8);
        burdon_plug(l = 20, d_in = variants_burdon_d_in, d_out = 17);
        translate([0, 0, 20]) for (i=[0, 90, 180, 270]) rotate([0, 0, i]) support_struct();
    }

    // horn at the end
    horn(length = 80, d_end = 40, thickness = 4, d_sock_in = 19, d_sock_out = variants_burdon_d_out, l_sock = 20);
}
