use <clips/clip-mmu.scad>

$fn = 100;
eps = 0.2;

linear_bearing_d = 25;
x_size = 200 - linear_bearing_d;

drill_ball_bearing_h = 11;
drill_ball_bearing_d_in = 9;
drill_ball_bearing_d = 22;

thickness_coeff = 2;
drill_ball_bearing_embedding_h = drill_ball_bearing_h * thickness_coeff;
drill_ball_bearing_embedding_d = drill_ball_bearing_d * thickness_coeff * 0.8;

d_clearance = 0.5;
h_clearance = 1;

latch_l = 40;

clear("white") X(-drill_ball_bearing_embedding_d / 2 - 5.2) Y(-latch_l / 4 - 0.5) tightening_clip();
    
difference() {
clear("white") tube(h = drill_ball_bearing_embedding_h, d = drill_ball_bearing_embedding_d, wall = (drill_ball_bearing_embedding_d - linear_bearing_d) / 2);
    X(-(drill_ball_bearing_embedding_d - 10) / 2) box(x = 15, y = 4, z = drill_ball_bearing_embedding_h + eps);
}