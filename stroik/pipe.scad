include <reed/pipe.scad>
include <variants-pipe.scad>
include <variants-reed-pipe.scad>

$fn=100;

module my_pipe(){
    pipe(l=variants_pipe_len,
        d_in=variants_pipe_in_d,
        reed_d_in=variants_reed_pipe_in_diameter,
        thickness_bottom=variants_pipe_thickness_bottom,
        thickness_top=variants_pipe_thickness_top,
        holes=variants_pipe_holes
    );
}

module cutting_operator(where_coeff, connector_len, thickness) {
    translate([0,0,variants_pipe_len * where_coeff]) {
        union() {
            // connector
            base_pipe(l = connector_len, d = variants_pipe_in_d + thickness, thickness_bottom = variants_pipe_thickness_bottom, thickness_top = variants_pipe_thickness_bottom);
            // the upper rest
            translate([0,0,connector_len - eps/2]) base_pipe(l = variants_pipe_len, d = variants_pipe_in_d-eps, thickness_bottom = variants_pipe_thickness_bottom + 10, thickness_top = variants_pipe_thickness_bottom + 10);
        }
    }
}

// first / bottom half of the pipe

where_cut = 0.53;
my_connector_len = 18   ;

difference() {
    my_pipe();
    cutting_operator(where_coeff = where_cut, connector_len = my_connector_len, thickness = 4);
}

// second / upper half of the pipe
%intersection() {
    my_pipe();
    cutting_operator(where_coeff = where_cut, connector_len = my_connector_len, thickness = 4);
}
// support_struct();
// rotate([0,0,90]) support_struct();
// rotate([0,0,180]) support_struct();
// rotate([0,0,270]) support_struct();


// translate([0, 0, -40]) rotate([180, 0, -90]) horn();
