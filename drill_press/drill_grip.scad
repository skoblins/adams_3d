include <BOSL2/std.scad>
include <BOSL2/screws.scad>

$fn=50;

outer_d = 190;
inner_d = 145;

module drill_grip1() {
    /*projection(cut=true) xrot(-90) */diff() {
                zcyl(h = 200, d = outer_d) {
                    attach(TOP) {
                        tag("remove") zrot(90) screw_hole("M100,42",anchor=TOP, orient=TOP, thread=true/*, bevel1="reverse"*/);
                    };
                    tag("remove") {
                        down(20) {
                            directions = [LEFT, LEFT+FRONT, FRONT, RIGHT+FRONT, RIGHT, RIGHT + BACK, BACK, LEFT + BACK];
                            xnum = 3;
                            xspacing = 50;
                            for(dir = directions) {
                                attach(dir) {
                                    ycopies(spacing=xspacing, n=xnum) screw_hole("M24,50",anchor=TOP,thread=true,bevel1="reverse",teardrop=true, spin=180);
                                }
                            }
                        }
                        align(BOTTOM, inside=true, overlap=-1)
                            zcyl(h = 160, d = inner_d);
                    }
                    {
                        stem_support_dirs=[LEFT+FRONT, RIGHT+FRONT, RIGHT + BACK, LEFT + BACK];
                        for(dir = stem_support_dirs) {
                                attach(dir) {
                                    cube([20, 20, 10]);
                                }
                            }
                    }
                }
        }
}

height_of_segment = 50;
height_of_segment_screw = 20;

module solid_1(){
    diff(remove="remove_solid_1") {
        zcyl(h = height_of_segment, d1 = 90, d2=50) {
            attach(BOTTOM) {
                    zrot(90) screw("M80,20", tolerance="8e", anchor=TOP, orient=BOTTOM, thread=true, bevel1 = false, bevel2=false);
            };
            attach(TOP) cuboid([130, 20, 40], rounding=5, /*edges=[RIGHT, LEFT],*/ anchor=TOP );       
            attach(TOP, overlap=-0.01) {
                tag("remove_solid_1") zcyl(h=9.1, d=28.1, anchor=TOP);
            }
        }
        tag("remove_solid_1") zcyl(h=height_of_segment*2, d=10);
    }
}

module solid_2(){
    diff(remove="remove_solid_2") {
        zcyl(h = height_of_segment, d1 = 130, d2 = 90) {
            attach(BOTTOM) {
                    zrot(90) screw("M100,40", tolerance="8e", anchor=TOP, orient=BOTTOM, thread=true, bevel1=false, bevel2=false)
                    attach(BOTTOM, overlap=-0.01) tag("remove_solid_2") zcyl(h=9.1, d=28.1, anchor=TOP);
            };
            attach(TOP) {
                zrot(90) cuboid([180, 20, 40], rounding=5, /*edges=[RIGHT, LEFT],*/ anchor=TOP );
            }
            attach(TOP, overlap=19.99) {
                tag("remove_solid_2") zcyl(h=9.1, d=28.1, anchor=TOP);
                tag("remove_solid_2") zrot(90) screw_hole("M80,21", tolerance="8G", anchor=TOP, orient=BOTTOM, thread=true, bevel1=false, bevel2=false);
                tag("remove_solid_2") zcyl(h=height_of_segment*2, d=10, anchor=TOP);
            }
        }
    }
}

module solid_2_test(){
    up(40) zrot_copies([0,90]) cuboid([85, 10, 10], anchor=TOP );
    diff(remove="remove_solid_2") {
        zrot(90) screw("M100,40", tolerance="8e", anchor=TOP, orient=BOTTOM, thread=true, bevel1=false, bevel2=false)
        attach(BOTTOM, overlap=-0.01) tag("remove_solid_2") zcyl(h=51, d=85, anchor=TOP);
    }
}

diff(remove="remove_main"){
    solid_1();
     tag("remove_main") zcyl(h=height_of_segment*2, d=10);
     down(150) solid_2();
     down(400) drill_grip1();
    //solid_2_test();
}
//attach(BOTTOM) {
//}
