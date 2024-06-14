include <constructive/constructive-compiled.scad>
include <../stroik/variants-pipe.scad>

$fn = 100;

eps = 0.8;
1st_in_diameter = 37.66; //[mm]
1st_in_height = 15;
2nd_1st_d = 30.04;
2nd_2nd_d = 25.5;
2nd_h = 6.5;
3rd_d = 8.12;
3rd_h = 8;

assemble() {
    add() {
        TOUP() stack(TOUP) {
            h = (1st_in_height + 2nd_h + 3rd_h) * 1.1;
            d = 1st_in_diameter * 1.3;
            tube(h = h, d = d, solid = true)
            tube(h = pipe_plug_len, d = variants_pipe_plug_in_d - eps, solid = true)
            tube(h = h, d = variants_pipe_in_d - eps, solid = true);
        }
    }
    remove() {
        Z(-eps) TOUP() stack(TOUP) {
            tube(h = margin(1st_in_height, eps), d = margin(1st_in_diameter, eps), solid = true)
            Z(-eps) tube(h = margin(2nd_h, eps), d1 = margin(2nd_1st_d, eps), d2 = 2nd_2nd_d, solid = true)
            Z(-eps) tube(h = margin(3rd_h, eps), d1 = margin(3rd_d, eps), d2 = 0, solid = true);
        }
    }
}
