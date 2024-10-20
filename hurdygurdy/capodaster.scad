include <BOSL2/std.scad>

bottom_width = 13;
length = 20;

screw_z_off = 7;
screw_x_off = 9.5;
heigth = 5;

eps = 0.01;

diff(){
    cuboid([bottom_width, length, heigth], rounding = bottom_width, edges = [BACK+LEFT])
    {
        align(BACK+RIGHT)
        cuboid([bottom_width, length, heigth], rounding = bottom_width, edges = [BACK+RIGHT])
        tag("remove") right(bottom_width/2) align(LEFT) left(eps) cuboid([bottom_width/2, length, heigth+eps], rounding = bottom_width/2, edges = [FWD+RIGHT])
        align(RIGHT, FWD)
        tag("") fwd(5) right(bottom_width/2) cuboid([bottom_width, length, heigth], spin = -90, rounding = bottom_width, edges = [BACK+RIGHT])
        tag("remove") right(bottom_width/2) align(LEFT) left(eps) cuboid([bottom_width/2, length, heigth+eps], rounding = bottom_width/2, edges = [FWD+RIGHT]);
        
        align(RIGHT) cuboid([bottom_width, length, heigth])
        tag("remove") fwd(length/4) align(CENTER) cuboid([bottom_width+eps, length+eps, heigth+eps], rounding = bottom_width, edges = [BACK+LEFT]);
        tag("remove") align(FWD+TOP, inside=true) right(screw_x_off - bottom_width/2) back(screw_z_off - (9 + eps)/2) up(eps/2) zcyl(d = 9 + eps, h = 2 + eps, $fn = 50, anchor = CENTER)
        tag("remove") align(BOTTOM) up(eps/2) zcyl(d = 4 + eps, h = heigth, $fn = 50, anchor = CENTER);
    }
}
 