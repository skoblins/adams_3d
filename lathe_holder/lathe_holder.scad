include <constructive/constructive-compiled.scad>
include <../stroik/variants-pipe.scad>


$fn = 200;

eps = 0.6;
eps2 = 0.001;
2nd_1st_d = 30.04;
2nd_2nd_d = 25.5;

1st_in_diameter = 37.66; //[mm]
1st_in_height = 15;
2nd_h = 6.5;
3rd_d = 8.12;
3rd_h = 8;

// for the pipe
// assemble() {
//     add() {
//         TOUP() stack(TOUP) {
//             h = (1st_in_height + 2nd_h + 3rd_h) * 1.1;
//             d = 1st_in_diameter * 1.3;
//             tube(h = h, d = d, solid = true)
//             tube(h = pipe_plug_len + reed_socket_len, d = variants_pipe_plug_in_d - eps, solid = true)
//             tube(h = h, d = variants_pipe_in_d - eps, solid = true);
//         }
//     }
//     remove() {
//         Z(-eps) TOUP() stack(TOUP) {
//             tube(h = margin(1st_in_height, eps), d = margin(1st_in_diameter, eps), solid = true)
//             Z(-eps) tube(h = margin(2nd_h, eps), d1 = margin(2nd_1st_d, eps), d2 = 2nd_2nd_d, solid = true)
//             Z(-eps) tube(h = margin(3rd_h, eps), d1 = margin(3rd_d, eps), d2 = 0, solid = true);
//         }
//     }
// }

// for the burdon pipe
// assemble() {
//     add() {
//         TOUP() stack(TOUP) {
//             h = (1st_in_height + 2nd_h + 3rd_h) * 1.1;
//             d = 1st_in_diameter * 1.3;
//             tube(h = h, d = d, solid = true)
//             #tube(h = 40, d = 20 - eps, solid = true)
//             tube(h = h, d = variants_pipe_in_d - eps, solid = true);
//         }
//     }
//     remove() {
//         Z(-eps) TOUP() stack(TOUP) {
//             tube(h = margin(1st_in_height, eps), d = margin(1st_in_diameter, eps), solid = true)
//             Z(-eps) tube(h = margin(2nd_h, eps), d1 = margin(2nd_1st_d, eps), d2 = 2nd_2nd_d, solid = true)
//             Z(-eps) tube(h = margin(3rd_h, eps), d1 = margin(3rd_d, eps), d2 = 0, solid = true);
//         }
//     }
// }

include <BOSL2/std.scad>
cases = [0,2,4,6, 8];
for(contact_surface_rot=cases) {
    right(contact_surface_rot*1st_in_diameter*1.5) diff() {
        h = (1st_in_height + 2nd_h + 3rd_h) * 1.1;
        d = 1st_in_diameter * 1.3;
        zcyl(h = h, d = d, anchor=BOTTOM) {
            attach(TOP) zcyl(h = h, d = variants_pipe_in_d - eps, anchor=BOTTOM);
            attach(TOP) {
                intersection() {
                    zcyl(h = 50, d=d, anchor=BOTTOM);
                    xrot(contact_surface_rot) zcyl(h=10, d=100)
                        xcopies(n=4, spacing=1st_in_diameter/3) ycopies(n=4, spacing=1st_in_diameter/3) attach(TOP, overlap=2)
                            xrot(-contact_surface_rot) prismoid([6,6], [0,0], h=6);
                }
            };
            attach(RIGHT, overlap=0) tag("remove") text3d(str(contact_surface_rot), h=1.5, size=15, anchor=CENTER);
        }

        tag("remove")
            down(eps2) zcyl(h = 1st_in_height + eps, d = 1st_in_diameter + eps, anchor=BOTTOM)
                attach(TOP, overlap=eps2) zcyl(h = 2nd_h + eps, d1 = 2nd_1st_d + eps, d2 = 2nd_2nd_d, anchor=BOTTOM)
                    attach(TOP, overlap=eps2) zcyl(h = 3rd_h + eps, d1 = 3rd_d + eps, d2 = 0, anchor=BOTTOM);

    }
}