use <connectors/lin_screw.scad>
use <connectors/snap.scad>
use <clips/clip-mmu.scad>

$fn = 100;

linear_bearing_d = 25;

drill_ball_bearing_h = 5;
drill_ball_bearing_d_in = 9;
drill_ball_bearing_d = 22;

thickness_coeff = 2;
drill_ball_bearing_embedding_h = drill_ball_bearing_h * thickness_coeff;
drill_ball_bearing_embedding_d = drill_ball_bearing_d * thickness_coeff * 0.8;


latch_l = 40;


module linear_bearing(
    drill_ball_bearing_embedding_d = drill_ball_bearing_embedding_d,
    latch_l = latch_l,
    drill_ball_bearing_embedding_h = drill_ball_bearing_embedding_h,
    linear_bearing_d = linear_bearing_d
) {
    eps = 0.2;
    d_clearance = 0.5;
    h_clearance = 1;
    %X(-drill_ball_bearing_embedding_d / 2 - 5.2) Y(-latch_l / 4 - 0.5) tightening_clip();
    
    difference() {
        union() {
            tube(h = drill_ball_bearing_embedding_h, d = drill_ball_bearing_embedding_d, wall = (drill_ball_bearing_embedding_d - linear_bearing_d) / 2);
            X(drill_ball_bearing_embedding_d/2 - (4+1.2)/2) Z(-drill_ball_bearing_embedding_h/2) TODOWN() turnYZ(180) snap_round(4, 3, 1.2);
            X(drill_ball_bearing_embedding_d/2 - (4+1.2)/2) Z(drill_ball_bearing_embedding_h/2) TOUP() snap_round(4, 3, 1.2);
        }
        X(-(drill_ball_bearing_embedding_d - 10) / 2) box(x = 15, y = 4, z = drill_ball_bearing_embedding_h + eps);
    }
}

module linear_bearing_complementary(
    drill_ball_bearing_embedding_d = drill_ball_bearing_embedding_d,
    latch_l = latch_l,
    drill_ball_bearing_embedding_h = drill_ball_bearing_embedding_h,
    linear_bearing_d = linear_bearing_d
) {
    eps = 0.2;
    d_clearance = 0.5;
    h_clearance = 1;
    
    difference() {
        union() {
            // upper ring
            Z(drill_ball_bearing_embedding_h/2 + drill_ball_bearing_embedding_h/4)
                tube(h = drill_ball_bearing_embedding_h/2, dInner = linear_bearing_d + 1/*correction for the Y oriented print*/, dOuter = drill_ball_bearing_embedding_d + 2 /*correction for the open snap*/);
            
            // lower ring
            Z(-drill_ball_bearing_embedding_h/2 - drill_ball_bearing_embedding_h/4)
                tube(h = drill_ball_bearing_embedding_h/2, dInner = linear_bearing_d + 1/*correction for the Y oriented print*/, dOuter = drill_ball_bearing_embedding_d + 2 /*correction for the open snap*/);
        }
        union() {
            X(drill_ball_bearing_embedding_d/2 - (4+1.2)/2) Z(drill_ball_bearing_embedding_h/2 - eps/2) TOUP() snap_round_complement(4 + eps, 3, 1.2);
            X(drill_ball_bearing_embedding_d/2 - (4+1.2)/2) Z(-drill_ball_bearing_embedding_h/2 + eps) TODOWN() turnYZ(180) snap_round_complement(4 + eps, 3, 1.2);
        }
        // #segment_with_square_nuts(length = 25, height = 10, width = 30, screw_head_h = 5, screw_head_d = 8.5, screw_d = 5, nut_height = 8, nut_width = 3);
    }

}

linear_bearing(
    drill_ball_bearing_embedding_d = drill_ball_bearing_embedding_d,
    latch_l = latch_l,
    drill_ball_bearing_embedding_h = drill_ball_bearing_embedding_h,
    linear_bearing_d = linear_bearing_d
);

// linear_bearing_complementary(
//     drill_ball_bearing_embedding_d = drill_ball_bearing_embedding_d,
//     latch_l = latch_l,
//     drill_ball_bearing_embedding_h = drill_ball_bearing_embedding_h,
//     linear_bearing_d = linear_bearing_d
// );