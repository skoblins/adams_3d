include <BOSL2/std.scad>
include <BOSL2/screws.scad>

$fn=100;

diff() {
    tag("remove") zcyl(h = 210, d = 10)
    tag("") zcyl(h = 100, d1 = 100, d2 = 50)
        align(BOTTOM)
            zcyl(h = 200, d = 240)
                tag("remove") {
                    down(20) {
                        directions = [LEFT, LEFT+FRONT, FRONT, RIGHT+FRONT, RIGHT, RIGHT + BACK, BACK, LEFT + BACK];
                        xnum = 3;
                        xspacing = 50;
                        for(dir = directions) {
                            attach(dir) {
                                ycopies(spacing=xspacing, n=xnum) screw_hole("M16,50",anchor=TOP,thread=true,bevel1="reverse",teardrop=false);
                                // down(42) ycopies(spacing=xspacing, n=xnum) {
                                //     nut("M16", thickness="thick", thread="none");
                                //     nut("M14", thickness="thick", thread="none");
                                // }
                            }
                        }
                    }
                align(BOTTOM, inside=true, overlap=-1)
                    zcyl(h = 160, d = 160);
                }
    // bearing 1
    tag("remove") up(40) zcyl(h = 10, d = 22);
    down(10) zcyl(h = 10, d = 22);
    down(60) zcyl(h = 10, d = 22);
}
