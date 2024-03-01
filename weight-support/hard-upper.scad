// base
cube([25,25,3]);

// banks
cube([6.5, 20, 4.5]);
translate([25-6.5, 0, 0]) cube([6.5, 20, 4.5]);

module clip(length){
    linear_extrude(height=length,center=false, convexity=10, twist = 0) polygon(points = [[0,0], [0,10], [2.1,7.5],[1.5,7.5],[1.5,0]], paths = [[0,1,2,3,4]], convexity = 10);
}

// walls
translate([2.5,0,0]) rotate([90,0,90]) clip(length=20);
translate([6.5,21,0]) rotate([90,0,270]) clip(6.5);
translate([25,21,0]) rotate([90,0,270]) clip(6.5);

// clips
translate([0,14,0]) rotate([90,0,0]) clip(length=10);

translate([25,4,0]) rotate([90,0,180]) clip(length=10);

// soft part holder
difference() {
    translate([2,2,-1])cube([21,21,1]);
    translate([3,3,-1.05])cube([19,19,1.05]);
}
