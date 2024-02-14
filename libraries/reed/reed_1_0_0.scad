include <reed.scad>

module reed_base_hollow_cap(total_length, end_length, cap_length, d, wall_thickness){
difference(){
        reed_base(total_length, end_length, d);
        translate([0,0,-0.1])rotate([0.5,0,0])cylinder(h=total_length*1.1, d=d-wall_thickness*2,center = false);
    }
    translate([0,0,total_length-cap_length]) cylinder(h=cap_length,d=d, center=false);
}

module reed_base_flattened(total_length, end_length, cap_length, d, wall_thickness, flattening_degree){
    difference(){
            reed_base_hollow_cap(total_length, end_length, cap_length, d, wall_thickness);
            translate([-d/2,d/2,end_length+d]) rotate([flattening_degree,0,0]) cube([d,d,(total_length-end_length-d)*1.1],center=false);
    }
    // translate([-d/2,d/2,end_length+d]) rotate([flattening_degree,0,0]) cube([d,d,(total_length-end_length-d)*1.1],center=false);
}

module reed_base_hole(total_length, end_length, cap_length, d, wall_thickness, flattening_degree, hole_proportions){
    difference(){
        reed_base_flattened(total_length, end_length, cap_length, d, wall_thickness, flattening_degree);
        translate([0,d/2,hole_proportions[0]*(total_length)]){
            rotate([90,0,0]){
                resize([d*hole_proportions[1],hole_proportions[2]*(total_length-end_length-cap_length)/5,d*hole_proportions[3]]){
                    cylinder(h=1.2,r1=d/4.5,r2=d/3,center=false);
                }
            }
        }
    }
}

module reed_base_string(total_length, end_length, cap_length, d, wall_thickness, flattening_degree, hole_proportions){
    my_text = str("L", total_length, " EL", end_length, " CP", cap_length, " D", d, " WT", wall_thickness, " FD", flattening_degree, " HP", hole_proportions);
    difference(){
        reed_base_hole(total_length, end_length, cap_length, d, wall_thickness, flattening_degree, hole_proportions);
        translate([d/8,-d/2+wall_thickness/8, end_length+d]) rotate([0,-90,90]) rotate([flattening_degree, 0, 0]) linear_extrude(wall_thickness/4) text(my_text, size = (total_length - end_length)/48);
    }
    
}

module reed_base_leaf_holder(total_length, end_length, cap_length, d, wall_thickness, flattening_degree, hole_proportions){
    difference(){
        reed_base_string(total_length, end_length, cap_length, d, wall_thickness, flattening_degree, hole_proportions);
        translate([0,0,end_length]){
            pipe(length=d, outer_diameter=d+wall_thickness, thickness=wall_thickness, center=false);
        }
    }
    rotate([0,0, 270-(holder_completeness_percent)/2*360/100]) {
        translate([0,0,end_length]){
            partial_pipe(length=d, outer_diameter=d, thickness=wall_thickness/1.5, completeness_percent=holder_completeness_percent);
        }
    }
}

module reed(total_length, end_length, cap_length, d, wall_thickness=1, flattening_degree=2, hole_proportions=[0.75,0.3,3,0.4]){
    reed_base_leaf_holder(total_length, end_length, cap_length, d, wall_thickness, flattening_degree, hole_proportions);
}

module leaf_holder(total_length, end_length, d, wall_thickness, flattening_degree) {
    echo(str("leaf_holder(", total_length, ",", end_length, ",", d, ", ", wall_thickness, ", ", flattening_degree, ")"));
    rotate([0,0,90-(100-holder_completeness_percent)/2*360/100]) {
        echo(str("rotate([0,0,", 90-(100-holder_completeness_percent)/2*360/100, "]))"));
        translate([0,0,end_length]){
            partial_pipe(length=d-0.02, outer_diameter = d + wall_thickness*3, thickness=wall_thickness*2, completeness_percent=(100-holder_completeness_percent));
        }
    }
}

module leaf_plane(total_length, end_length, d, wall_thickness, flattening_degree, flattening_offset, thickness_offset){
    
    translate([0, -wall_thickness/2 - sin(flattening_offset) * (total_length - end_length), total_length - 0.3]) rotate([-(flattening_degree + flattening_offset), 180, 0]) intersection(){
        translate([-d/2, d/2 + wall_thickness/2, 0]) rotate([flattening_degree, 0, 0]) cube([d, wall_thickness/2 + thickness_offset, (total_length-end_length - d)], center = false);
        translate([0, /*d/2 - */wall_thickness/2, 0]) cylinder(h = (total_length - end_length), d = d, center = false);
    }
}

module leaf(total_length, end_length, cap_length, d, wall_thickness, flattening_degree, hole_proportions, flattening_offset, thickness_offset){
    leaf_holder(total_length, end_length, d, wall_thickness, flattening_degree);
    leaf_plane(total_length, end_length, d, wall_thickness, flattening_degree, flattening_offset, thickness_offset);
}
