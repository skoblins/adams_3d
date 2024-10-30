include <BOSL2/std.scad>

clearance = 0.4;
eps = 0.01;
PI = 3.141592653589793238462643383279502884197;

module linear_bearing_with_tightening_clip(h=10, dInner=5, dOuter=10, dInnerLoose=6, anchor=CENTER, spin=0, orient=UP) {
    assert(dInner < dInnerLoose, "Loosening clip diameter must be more than bearing inner diameter");
    assert(dOuter > dInner, "Bearing outer diameter must be greater than bearing inner diameter");
    assert(h > 0, "Height must be greater than zero");
    assert(dInner > 0, "Inner diameter must be greater than zero");
    assert(dOuter > 0, "Outer diameter must be greater than zero");
    assert(dInnerLoose > 0, "Tightening clip diameter must be greater than zero");

    thickness = (dOuter - dInner)/2;
    travel = PI * (dInnerLoose-dInner);
    travelOuter = travel * dOuter/dInner;
    mainAxleBearingHeight = h/4 - 10/7*clearance;
    mainAxleBearingSizeCoeff = 0.3;
    mainAxleD = mainAxleBearingSizeCoeff * dOuter/2;

    sideAxleBearingHeight = 2/3*mainAxleBearingHeight;

    attachementRight = TOP+(travel+(mainAxleBearingSizeCoeff)*dOuter)/PI/dOuter*4*RIGHT;
    attachementRightForLatchRod = TOP+(travel+(mainAxleBearingSizeCoeff+mainAxleD)*dOuter)/PI/dOuter*4*RIGHT;
    attachementLeft = TOP+(travel+(mainAxleBearingSizeCoeff)*dOuter)/PI/dOuter*4*LEFT;

    overlapCorrectionSupport = 0.02*dOuter;
    overlapCorrectionAxleBearing = (mainAxleBearingSizeCoeff-0.1)*dOuter;

    attachable(anchor = anchor, spin = spin, orient = orient, size = [dOuter, dOuter, h]) {
        tag_diff("clip", "bearingInner gap axleHole axleHole2", "axle") {
            tag("bearingOuter") ycyl(h = h, d = dOuter) {
                tag("bearingInner") ycyl(h = h+eps, d = dInner, chamfer = -0.5);
                tag("gap") align(TOP, inside=true) cube([clearance, h+eps, thickness*5], center = true);
                tag("support") attach([attachementRight], BOTTOM, overlap=overlapCorrectionSupport) cuboid([mainAxleBearingHeight, (mainAxleBearingSizeCoeff-0.005)*dOuter, (mainAxleBearingSizeCoeff)*dOuter+travel/2], chamfer=0.5, edges="Z")
                    tag("axleBearing") align(TOP, overlap=overlapCorrectionAxleBearing) xcyl(h = mainAxleBearingHeight, d = mainAxleBearingSizeCoeff * dOuter)
                        tag("axleHole") xcyl(h=mainAxleBearingHeight+eps, d=mainAxleD + clearance)
                            tag("axle") xcyl(h=mainAxleBearingHeight + 2*sideAxleBearingHeight+2*clearance, d=mainAxleD)
                                tag("axle") align([LEFT,RIGHT]) xcyl(h=2*clearance, d=mainAxleD*1.9);

                tag("support") attach([attachementLeft], BOTTOM, overlap=overlapCorrectionSupport) cuboid([mainAxleBearingHeight, (mainAxleBearingSizeCoeff-0.005)*dOuter, (mainAxleBearingSizeCoeff)*dOuter+travel/2], chamfer=0.5, edges="Z")
                    tag("axleBearing") align(TOP, overlap=overlapCorrectionAxleBearing) xcyl(h = mainAxleBearingHeight, d = mainAxleBearingSizeCoeff * dOuter)
                        tag("axleHole") xcyl(h=mainAxleBearingHeight+eps, d=mainAxleD + clearance)
                            tag("axle") xcyl(h=mainAxleBearingHeight+clearance, d=mainAxleD) {
                                tag("axle") align([LEFT,RIGHT]) up(travel/(2*(2^0.5))) fwd(travel/(2*(2^0.5))) xcyl(h=sideAxleBearingHeight, d=mainAxleD+travel);
                                tag("axle") align([LEFT]) up(travel/(2*(2^0.5))) fwd(travel/(2*(2^0.5))) left(sideAxleBearingHeight) xcyl(h=clearance/2, d=mainAxleD+travel)
                                    align(LEFT) xcyl(h=3*clearance, d=mainAxleD*1.9+travel);
                                tag("axle") align([RIGHT]) up(travel/(2*(2^0.5))) fwd(travel/(2*(2^0.5))) right(sideAxleBearingHeight) xcyl(h=clearance/2, d=mainAxleD+travel)
                                    align(RIGHT) xcyl(h=3*clearance, d=mainAxleD*1.9+travel);
                            }

                // Binding rod
                yflip_copy()
                    conv_hull("axleHole2") hide("axleBearing1 axleHole axle support") {
                        tag("support") attach([attachementLeft], BOTTOM, overlap=overlapCorrectionSupport) cuboid([mainAxleBearingHeight, (mainAxleBearingSizeCoeff-0.005)*dOuter, (mainAxleBearingSizeCoeff)*dOuter+travel/2], chamfer=0.5, edges="Z")
                        tag("axleBearing1") align(TOP, overlap=overlapCorrectionAxleBearing) xcyl(h = mainAxleBearingHeight, d = mainAxleBearingSizeCoeff * dOuter)
                            tag("axleHole") xcyl(h=mainAxleBearingHeight+eps, d=mainAxleD + clearance)
                                tag("axle") xcyl(h=mainAxleBearingHeight+clearance, d=mainAxleD) {
                                    tag("axle") align([LEFT]) up(travel/(2*(2^0.5))) fwd(travel/(2*(2^0.5))) xcyl(h=sideAxleBearingHeight, d=mainAxleD+travel) {
                                        tag("axleBearing2") xcyl(h=sideAxleBearingHeight-eps, d=(mainAxleD*1.9)+travel);
                                        tag("axleHole2") xcyl(h=sideAxleBearingHeight+eps, d=mainAxleD+travel+clearance);
                                    }
                                }

                        tag("support") attach([attachementRight], BOTTOM, overlap=overlapCorrectionSupport) cuboid([mainAxleBearingHeight, (mainAxleBearingSizeCoeff-0.005)*dOuter, (mainAxleBearingSizeCoeff)*dOuter+travel/2], chamfer=0.5, edges="Z")
                        tag("axleBearing1") align(TOP, overlap=overlapCorrectionAxleBearing) xcyl(h = mainAxleBearingHeight, d = mainAxleBearingSizeCoeff * dOuter)
                            tag("axleHole") xcyl(h=mainAxleBearingHeight+eps, d=mainAxleD + clearance)
                                tag("axle") xcyl(h=mainAxleBearingHeight+2*sideAxleBearingHeight+2*clearance, d=mainAxleD) {
                                    tag("axleBearing2") align([RIGHT],inside=true, shiftout=-clearance/2) xcyl(h=sideAxleBearingHeight, d=mainAxleD*1.9);
                                    tag("axleHole2") align([RIGHT],inside=true) xcyl(h=sideAxleBearingHeight+clearance, d=mainAxleD+clearance);
                                    tag("axle") align([RIGHT]) xcyl(h=2*clearance, d=mainAxleD*1.9);
                                }
                    }

                // latch rod
                yflip_copy(offset = mainAxleBearingHeight/*2*sideAxleBearingHeight*/ + 3/2*clearance-eps)
                    conv_hull("rodConnector") hide("axleBearing1 axleHole axle support") {
                        tag("support") attach([attachementLeft], BOTTOM, overlap=overlapCorrectionSupport) cuboid([mainAxleBearingHeight, (mainAxleBearingSizeCoeff-0.005)*dOuter, (mainAxleBearingSizeCoeff)*dOuter+travel/2], chamfer=0.5, edges="Z")
                        tag("axleBearing1") align(TOP, overlap=overlapCorrectionAxleBearing) xcyl(h = mainAxleBearingHeight, d = mainAxleBearingSizeCoeff * dOuter)
                            tag("axle") xcyl(h=mainAxleBearingHeight+clearance, d=mainAxleD) 
                                tag("axle") align([LEFT]) up(travel/(2*(2^0.5))) fwd(travel/(2*(2^0.5))) xcyl(h=sideAxleBearingHeight, d=mainAxleD+travel)
                                    tag("axleBearing2") xcyl(h=sideAxleBearingHeight-eps, d=(mainAxleD*1.9)+travel);

                        tag("support") right(mainAxleD*2) attach([attachementRight], BOTTOM, overlap=overlapCorrectionSupport) cuboid([mainAxleBearingHeight, (mainAxleBearingSizeCoeff-0.005)*dOuter, (mainAxleBearingSizeCoeff)*dOuter+travel/2], chamfer=0.5, edges="Z")
                            tag("axleBearing1") align(TOP, overlap=overlapCorrectionAxleBearing) xcyl(h = mainAxleBearingHeight, d = mainAxleBearingSizeCoeff * dOuter)
                                tag("axle") xcyl(h=mainAxleBearingHeight+2*sideAxleBearingHeight+2*clearance, d=mainAxleD)
                                    tag("axleBearing2") align([RIGHT],inside=true, shiftout=-clearance/2) xcyl(h=sideAxleBearingHeight, d=mainAxleD*1.9)
                                        tag("rodConnector") align([RIGHT],inside=true, shiftout=-clearance/2) xcyl(h=mainAxleBearingHeight+2*sideAxleBearingHeight+3/2*clearance, d=mainAxleD*1.9);
                    }
            }
        }
        children();
    }
}

test=0;

// test
if(test == 1){
    $fn=200;
    linear_bearing_with_tightening_clip(h=10, dInner=25, dOuter=35, dInnerLoose=24);
}

// alignment test
if(test == 2) {
    $fn=25;
    linear_bearing_with_tightening_clip(){
        align(FWD) linear_bearing_with_tightening_clip() {
            align(UP) linear_bearing_with_tightening_clip();
            align(DOWN) linear_bearing_with_tightening_clip();
        }
        align(BACK) linear_bearing_with_tightening_clip() {
            align(UP) linear_bearing_with_tightening_clip();
            align(DOWN) linear_bearing_with_tightening_clip();
        }
        align(LEFT) linear_bearing_with_tightening_clip() {
            align(UP) linear_bearing_with_tightening_clip();
            align(DOWN) linear_bearing_with_tightening_clip();
        }
        align(RIGHT) linear_bearing_with_tightening_clip() {
            align(UP) linear_bearing_with_tightening_clip();
            align(DOWN) linear_bearing_with_tightening_clip();
        }
    }
}