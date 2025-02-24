include <BOSL2/std.scad>

module linear_tooth_bearing_element(length, width, height, tooth_height_coeff = 0.5) {
    xrot(90) right(-length/2) fwd(height/2) up(-width/2)
        linear_extrude(width)
            polygon(points = [
                [0,0],
                [length, 0],
                [length, height * tooth_height_coeff],
                [0, height],
                [0, height * tooth_height_coeff],
                [0, height * tooth_height_coeff],
            ]);
}

// %Y(-30) linear_tooth_bearing_element(length = 5, width = 15, height = 15);

module linear_tooth_bearing(length, width, height, tooth_length, tooth_height_coeff, anchor = CENTER, spin = 0, orient = UP) {
    eps = 0.01;
    tooth_no = floor(length / tooth_length);
    len_reminder = length - tooth_no * tooth_length;
    echo("tooth_linear.scad, linear_tooth_bearing: len_reminder: ", len_reminder);
    // attachable() {
        right(-length/2 + 1/tooth_no * length/2 + len_reminder/2) {
            for (i = [0:tooth_no-1]) {
                right(tooth_length * i) linear_tooth_bearing_element(tooth_length, width, height, tooth_height_coeff);
            }
        }
        if (len_reminder > 0) {
            right(( tooth_no * tooth_length + len_reminder/2 - eps)/2) up(-height/4) cube([len_reminder/2 + eps, width, height/2], center = true);
            right((-tooth_no * tooth_length - len_reminder/2 + 10 * eps)/2) up(-height/4) cube([len_reminder/2 + 10 * eps, width, height/2], center = true);
        }
        children();
    // }
}

// %linear_tooth_bearing(length = 100, width = 15, height = 10, tooth_length = 7);

module linear_tooth_complement(length, width, height, tooth_length, tooth_height_coeff, anchor = CENTER, spin = 0, orient = UP) {
    eps = 0.01;
    clearance = 0.8;
    tooth_no = floor(length / tooth_length);
    attachable(anchor = anchor, spin = spin, orient = orient, size = [length, width, height]) {
        up(0.1) {
            if (tooth_no > 0) {
                difference() {
                    up(tooth_height_coeff*height/2) cube([(tooth_no - 0.5) * tooth_length - eps, 0.5*width - eps - clearance, height * tooth_height_coeff/2 - eps], anchor = anchor, spin = spin, orient = orient);
                    linear_tooth_bearing(length, 0.5*width, height, tooth_length, tooth_height_coeff, anchor = anchor, spin = spin, orient = orient);
                }
            } else {
                // Create a small placeholder geometry to avoid attach errors
                cube([eps, eps, eps], anchor = anchor, spin = spin, orient = orient);
            }
        }
        children(); 
    }
}

// %up(15) linear_tooth_bearing_complement(length = 40, width = 15 - clearance, height = 10, tooth_length = 7);
