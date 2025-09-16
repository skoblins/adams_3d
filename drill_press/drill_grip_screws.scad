include <BOSL2/std.scad>
include <BOSL2/screws.scad>

$fn=400;

module M24() {
    spec = screw_info("M24", head="hex");
    newspec = struct_set(spec, ["head_size", 32]);
    diff() {
        screw(newspec, tolerance="8e", length=70) {
            attach(TOP, overlap=7) tag("remove") yrot(90) xrot(30) zcyl(h=50, d=7);
            attach(BOTTOM) zcyl(d1=17, d2=0, h=15, anchor=BOTTOM);
        }
    }
}

module M8() {
    screw("M10,10", head="none", tolerance="8e", bevel2=false) {
        align(TOP) cuboid([25, 10, 5], anchor=BOTTOM, chamfer=1);
        align(BOTTOM) cuboid([5, 0.2, 0.5], anchor=TOP);
    }
}

module M8_FDM() {
    back_half() M8();
    down(10.5) xrot(180) front_half() M8();
}


M8();
back(50) M8_FDM();
