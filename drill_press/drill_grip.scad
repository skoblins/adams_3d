include <BOSL2/std.scad>
include <BOSL2/screws.scad>
include <connectors/lin_screw.scad>

$fn=600;

outer_d = 175;
inner_d = 130;

// pipe bearing
pipe_bearing_outer_diameter = 40;
pipe_bearing_inner_diameter = 26;

bearing_stem_length = 20;

bearing_h = 60;

module drill_grip1() {
    stem_support_dirs=[LEFT+FRONT, RIGHT+FRONT, RIGHT + BACK, LEFT + BACK];
    main_directions = [LEFT, FRONT, RIGHT, BACK];
    /*projection(cut=true) xrot(-90) */diff() {
                zcyl(h = 200, d = outer_d) {
                    attach(TOP) {
                        tag("remove") zrot(90) screw_hole("M100,42", tolerance="8G", anchor=TOP, orient=TOP, thread=true/*, bevel1="reverse"*/);
                    };
                    tag("remove") {
                        down(20) {
                            xspacing = 50;
                            for(dir = [main_directions,stem_support_dirs]) {
                                attach(dir) {
                                    ycopies(spacing=xspacing, n=3) screw_hole("M24,50", tolerance="8G", anchor=TOP,thread=true,bevel1="reverse",teardrop=true, spin=180);
                                }
                            }
                        }
                        align(BOTTOM, inside=true, overlap=-1)
                            zcyl(h = 160, d = inner_d);
                    }
                    {
                        zrot(22.5) for(dir = stem_support_dirs) {
                                up(70) attach(dir) {
                                    cube([25,60,5], anchor=CENTER) attach(UP) antibend_rod_conn(35, 60, 25, orient=RIGHT, anchor=RIGHT);
                                }
                            }
                    }
                    {
                        zrot(22.5) for(dir = stem_support_dirs) {
                                up(-70) attach(dir) {
                                    cuboid([25,60,5], anchor=CENTER) attach(UP) antibend_rod_conn(35, 60, 25, orient=RIGHT, anchor=RIGHT) attach(BACK) left(2.5) prismoid(size1=[40,25],size2=[0,25], shift=[-20,0], h=50, anchor=BOTTOM);
                                }
                            }
                    }
                }
        }
}

module drill_grip2() {
    stem_support_dirs=[LEFT+FRONT, RIGHT+FRONT, RIGHT + BACK, LEFT + BACK];
    main_directions = [LEFT, FRONT, RIGHT, BACK];
    /*projection(cut=true) xrot(-90) */diff() {
                zcyl(h = 60, d = outer_d) {
                    tag("remove") {
                        down(0) {
                            for(dir = [main_directions,stem_support_dirs]) {
                                attach(dir) {
                                    screw_hole("M24,50", tolerance="8G", anchor=TOP,thread=true,bevel1="reverse",teardrop=true);
                                }
                            }
                        }
                        align(BOTTOM, inside=true, overlap=-1)
                            zcyl(h = 62, d = inner_d);
                    }
                    {
                        zrot(22.5) for(dir = stem_support_dirs) {
                                up(0) attach(dir) {
                                    cube([25,60,5], anchor=CENTER) attach(UP) antibend_rod_conn(35, 60, 25, orient=RIGHT, anchor=RIGHT);
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

module bearing() {
    diff() {
        zcyl(h=bearing_h, d=pipe_bearing_outer_diameter)
        attach(LEFT, overlap=2.5) cube([25, bearing_h, 5], anchor=CENTER) attach(UP) antibend_rod_conn(length = 35, width = bearing_h, height = 25, orient=RIGHT, anchor=RIGHT);
        tag("remove") zcyl(h = bearing_h+1, d = pipe_bearing_inner_diameter) {
            attach(RIGHT, overlap=2) zrot(90) screw_hole("M10,12", tolerance="8G", anchor=TOP, orient=BOTTOM, thread=true, bevel1=true, bevel2=true);
        }
    }
}

diff(remove="remove_main") {
    // solid_1();
    //  tag("remove_main") zcyl(h=height_of_segment*2, d=10);
    //  down(150) solid_2();
    //  down(400) drill_grip1();
    //  down(800) drill_grip2();
     up(100) {
       left(100) antibend_rod_conn_inside(length = 35, width = bearing_h, height = 25, clearance = 0.8, orient = FRONT)
       align(LEFT) cube([38, 29.5, 25]) align(LEFT) antibend_rod_conn_inside(length = 35, width = bearing_h, height = 25, clearance = 0.8);
        bearing();
     }
    //solid_2_test();
}
//attach(BOTTOM) {
//}
