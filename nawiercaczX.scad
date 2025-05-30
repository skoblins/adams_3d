include <BOSL2/std.scad>
include <BOSL2/screws.scad>
include <stroik/variants-reed-pipe.scad>
module rail(length=220, tolerance = 0, spin=0) {
    attachable(CENTER, spin, UP, size=[17.5 + tolerance,length,10]) {
        prismoid(size1=[22.5 + tolerance,length], h=10, xang=[90,45], yang=90, anchor=CENTER) {
            align(TOP, RIGHT+FRONT) down(0.01) cube([10 + tolerance, length, 2.5+0.01])
                attach(TOP) down(0.01) prismoid([15+tolerance,length], h=2.5+0.01, xang=45, yang=90, anchor=TOP, orient=BOTTOM);
        }
        children();
    }
}

module slider(length=30, spin) {
    attachable(CENTER, spin, UP, size=[31.25,length, 40]) {
        diff(){
            fwd(5) left(12.5) up(0.05)back(0.05)right(0.624)cube([27.50,length,2.5]) {
                align(TOP)
                    prismoid(size1=[27.5 ,length], h=10, xang=[90,45], yang=90, anchor=BOTTOM) {
                        align(TOP, RIGHT+FRONT, overlap=2.5)
                            right(1.25)cube([22.5,length,10]);
                        attach(RIGHT) screw_hole("M8,7",anchor=TOP,thread=true);
                    }
                align(LEFT, BOTTOM+FRONT, inside=true, shiftout=0.001) tag("remove") rail(length=length+1, tolerance=0.1);
            }
        }
        children();
    }
}

cube([100, 220, 5], anchor = CENTER) {
    align(LEFT, BOTTOM+FRONT)
        rail(tolerance=-0.1, spin=180);
    align(RIGHT, BOTTOM+FRONT)
        rail(tolerance=-0.1);
}
            
back(250) slider() {
    align(LEFT, UP+BACK) cube([30,30,10], anchor=BOTTOM);
    align(RIGHT) cube([30,40,10], anchor=BOTTOM);
}
back(300) screw("M8,20", thread=true) align(TOP+LEFT, inside=true) cuboid([20, 8, 2.5], anchor = BOTTOM, rounding=2, edges=[LEFT,RIGHT], except=[TOP, BOTTOM]);