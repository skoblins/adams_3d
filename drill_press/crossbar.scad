include <BOSL2/std.scad>
include <connectors/lin_screw.scad>

module crossbar(connector_length, width, middle_part_length, height) {
    antibend_rod_conn_inside(length = connector_length, width = width, height = height, screw_d = 3)
        align(RIGHT)
            cuboid([middle_part_length, width, height/2 - 0.4]) {
                back(width/2) align(FRONT) partition_mask(l=middle_part_length*3/4, cutsize=10, w=width, h=height/2 - 0.4, cutpath="sawtooth");
                align(RIGHT) antibend_rod_conn_inside(length = connector_length, width = width, height = height, screw_d = 3);
            }
}