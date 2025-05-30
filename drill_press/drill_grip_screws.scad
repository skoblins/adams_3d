include <BOSL2/std.scad>
include <BOSL2/screws.scad>

$fn=600;

spec = screw_info("M24", head="hex");
newspec = struct_set(spec, ["head_size", 32]);
diff() {
    screw(newspec, tolerance="8e", length=70) {
        attach(TOP, overlap=7) tag("remove") yrot(90) xrot(30) zcyl(h=50, d=7);
        attach(BOTTOM) zcyl(d1=17, d2=0, h=15, anchor=BOTTOM);
    }
}