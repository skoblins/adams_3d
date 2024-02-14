use <BOSL2/std.scad>

holder_completeness_percent = 33;

module pipe(length, outer_diameter, thickness, cap=0, center=true){
    if(cap == 0){
        difference(){
            cylinder(h=length, d=outer_diameter, center = center);
            translate([0,0,-0.1*length]) cylinder(h=length*1.3, d=outer_diameter-thickness*2, center = center);
        }
    } else {
        difference(){
            cylinder(h=length, d=outer_diameter, center = center);
            translate([0,0,-cap]) cylinder(h=length, d=outer_diameter-thickness*2, center = center);
        }
    }
}

module partial_pipe(length, outer_diameter, thickness, completeness_percent=33){
    echo(str("partial_pipe(", length, ", ", outer_diameter, ", ", thickness, ", ", completeness_percent));
    difference(){
        rotate_extrude(angle=completeness_percent*360/100, convexity = 2){
            translate([0.01, 0, 0]) square([outer_diameter/2 - 0.01, length], center = false);
        }
        translate([0,0,-0.1*length]) cylinder(h=length*1.2,d=outer_diameter - thickness*2, center = false);
    }
}

module reed_ending(total_length, end_length, d) {
    // pogrubienie przy mocowaniu
    translate([0,0,-end_length]){
        flute_count = 10;
        difference() { //karbowanie
            cylinder(h=end_length,r2=d*1.1/2,r1=d*0.9/2,center=false);
            for(i=[1:flute_count]){
                translate([0,0,i*end_length/flute_count]){
                    pipe(length=end_length/flute_count/2, outer_diameter=0.1+d*lerp(0.9, 1.1, i/flute_count), thickness=0.1, center=false);
                    // echo(i*end_length/flute_count);
                }
            } //karby
        } // karbowanie
    } // pogrubienie
}

module reed_base(total_length, end_length, d){
    translate([0, 0, end_length]) {
        // główny cylinder
        cylinder(h=total_length - end_length, d=d);
        reed_ending(total_length, end_length, d);
    } // wyrównanie po dodaniu końcówki
}