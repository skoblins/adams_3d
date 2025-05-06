include <BOSL2/std.scad>
include <BOSL2/screws.scad>

$fn=100;

outer_d = 190;
inner_d = 145;

module drill_grip1() {
    /*projection(cut=true) xrot(-90) */diff() {
        tag("remove") zcyl(h = 210, d = 10.1)
        tag("") zcyl(h = 100, d1 = 110, d2 = 70) {
            attach(BOTTOM) {
                // zcyl(h = 10, d = 100, anchor=TOP);
                zrot(90) screw("M100,40", tolerance="6f", anchor=TOP, orient=BOTTOM, thread=true, bevel2=false);
            };
            // align(BOTTOM)
            //     zcyl(h = 200, d = outer_d) {
            //         attach(TOP) {
            //             tag("remove") zrot(90) screw_hole("M100,42",anchor=TOP, orient=TOP, thread=true/*, bevel1="reverse"*/);
            //         };
            //         tag("remove") {
            //             down(20) {
            //                 directions = [LEFT, LEFT+FRONT, FRONT, RIGHT+FRONT, RIGHT, RIGHT + BACK, BACK, LEFT + BACK];
            //                 xnum = 3;
            //                 xspacing = 50;
            //                 for(dir = directions) {
            //                     attach(dir) {
            //                         ycopies(spacing=xspacing, n=xnum) screw_hole("M24,50",anchor=TOP,thread=true,bevel1="reverse",teardrop=true, spin=180);
            //                     }
            //                 }
            //             }
            //             align(BOTTOM, inside=true, overlap=-1)
            //                 zcyl(h = 160, d = inner_d);
            //         }
            //     }
        }
        // bearings
        tag("remove") up(40)
        zcyl(h = 9.1, d = 28.1)
        down(60) zcyl(h = 9.1, d = 28.1)
        down(60) zcyl(h = 9.1, d = 28.1);
        // cuts
        up(40)cube([150, 150, 10]);
    }
}

height_of_segment = 50;
height_of_segment_screw = 20;

module solid_1(){
    diff(remove="remove_solid_1") {
        zcyl(h = height_of_segment, d = 90) {
            attach(BOTTOM) {
                    zrot(90) screw("M80,20", tolerance="6f", anchor=TOP, orient=BOTTOM, thread=true, bevel2=false);
            };
            attach(TOP) cuboid([200, 50, height_of_segment_screw], rounding=5, /*edges=[RIGHT, LEFT],*/ anchor=TOP );       
            attach(TOP, overlap=-0.01) {
                tag("remove_solid_1") zcyl(h=9.1, d=28.1, anchor=TOP);
            }
        }
        tag("remove_solid_1") zcyl(h=height_of_segment*2, d=10);
    }
}

module solid_2(){
    diff(remove="remove_solid_2") {
        zcyl(h = height_of_segment, d1 = 90, d2 = 90) {
            attach(BOTTOM) {
                    zrot(90) screw("M100,40", tolerance="6f", anchor=TOP, orient=BOTTOM, thread=true, bevel2=false)
                    attach(BOTTOM, overlap=-0.01) tag("remove_solid_2") zcyl(h=9.1, d=28.1, anchor=TOP);
            };
            attach(TOP, overlap=19.99) {
                tag("remove_solid_2") zcyl(h=9.1, d=28.1, anchor=TOP);
                tag("remove_solid_2") zrot(90) screw_hole("M80,20", anchor=TOP, orient=BOTTOM, thread=true, bevel1=true, bevel2=false);
                tag("remove_solid_2") zcyl(h=height_of_segment*2, d=10, anchor=TOP);
            }
        }
    }
}

diff(remove="remove_main"){
    solid_1();
    tag("remove_main") zcyl(h=height_of_segment*2, d=10);
    down(150) solid_2();
}
//attach(BOTTOM) {
//}