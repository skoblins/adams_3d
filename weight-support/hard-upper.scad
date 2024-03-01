cube([25,25,3]);
cube([6.5, 20, 4.5]);
translate([25-6.5, 0, 0]) cube([6.5, 20, 4.5]);
translate([6,0,0]) cube([13, 1.5, 7]);
translate([0,20-1.5,0]) cube([6.5, 1.5, 7]);
translate([25-6.5,20-1.5,0]) cube([6.5, 1.5, 7]);
translate([0,14,0]) rotate([90,0,0]) linear_extrude(height=10,center=false, convexity=10, twist = 0) polygon(points = [[0,0], [0,9], [2,7],[1.5,7],[1.5,0]], paths = [[0,1,2,3,4]], convexity = 10);

translate([25,4,0]) rotate([90,0,180]) linear_extrude(height=10,center=false, convexity=10, twist = 0) polygon(points = [[0,0], [0,9], [2,7],[1.5,7],[1.5,0]], paths = [[0,1,2,3,4]], convexity = 10);
difference() {
    translate([2,2,-0.5])cube([21,21,0.5]);
    translate([3,3,-0.505])cube([19,19,0.51]);
}
