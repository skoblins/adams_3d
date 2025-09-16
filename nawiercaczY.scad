include <BOSL2/std.scad>
include <BOSL2/screws.scad>
include <stroik/variants-pipe.scad>

working_area_height = 50;
// base plate
base_plate_len_margin = 20;
base_plate_length = variants_pipe_len + base_plate_len_margin;
base_plate_width = 150;
base_plate_height = 5;

rail_width = 20;
rail_height = 20;
rail_slot_loosening = 0.1; // loosen the slot by this amount, to allow for easier assembly
rail_slot_depth = rail_width/8 + rail_slot_loosening;
rail_slot_height = rail_height/4 + rail_slot_loosening;

cart_width = rail_width * 1.25;
cart_length = cart_width;
cart_height = rail_height * 1.25;

cuboid([base_plate_width, base_plate_length, base_plate_height], anchor = BOTTOM) {
    align(TOP, [LEFT, RIGHT]) {
        cuboid([rail_width - 2*rail_slot_depth, base_plate_length, rail_slot_height], anchor = BOTTOM)
            align(TOP)
                cuboid([rail_width, base_plate_length, rail_height - rail_slot_height]);
    }
}

up(base_plate_height + rail_slot_loosening) fwd(base_plate_length/2 + cart_length) xcopies(base_plate_width - cart_width / 2 - rail_slot_depth + 2*rail_slot_loosening) zrot_copies([0, 180]) right(rail_width/2 - rail_slot_depth/2 + 2*rail_slot_loosening) {
    cuboid([rail_slot_depth - rail_slot_loosening, cart_length, rail_slot_height - 2*rail_slot_loosening], anchor = BOTTOM)
    align(RIGHT, BOTTOM+FRONT) cuboid([cart_width * 0.25, cart_length, cart_height + rail_slot_loosening])
    align(LEFT, TOP+FRONT) cuboid([cart_width * 0.5, cart_length, rail_height * 0.25]);
    // cuboid([cart_width, cart_length, cart_height], anchor = BOTTOM);
}
