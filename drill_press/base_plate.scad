include <BOSL2/std.scad>

eps=0.05;
module base_plate_part1(base_plate_part_length, base_plate_height, base_zipper_length, base_zipper_width, pipe_hose_height) {
    diff(remove="hose_pipe_bearing_hole", keep="hose_pipe_bearing")
        cuboid([base_plate_part_length, base_plate_part_length, base_plate_height]) {
            tag("hose_pipe_bearing_hole") right(base_plate_part_length/2-base_plate_pipe_hose_out_d/2) back(base_plate_part_length/2-base_plate_pipe_hose_out_d/2) align(TOP,overlap=base_plate_height/2) zcyl(d=pipe_bearing_inner_diameter+1, h=pipe_hose_height+eps, chamfer=-1)
            tag("") zcyl(d1=base_plate_pipe_hose_out_d, d2=base_plate_pipe_hose_out_d*3/4, h=pipe_hose_height);
            tag("") align(TOP, FRONT+LEFT) prismoid(size1=[claw_height,claw_height], size2=[0,0], h=claw_height, shift=[-claw_height/2,-claw_height/2]);
        }

    fwd(base_plate_part_length/2+1/2*base_zipper_width-eps) xcopies(n=2, spacing=base_zipper_length) segment_with_square_nuts(orient=FRONT, length = base_zipper_length, height = base_zipper_width, width = base_plate_height, screw_head_h = 5, screw_head_d = 8.5, screw_d = 5, nut_height = 8.5, nut_width = 3);
    ycopies(n=2, spacing=base_zipper_length) back(base_zipper_length/2) left(base_plate_part_length/2-eps) zrot(-90) back(-base_zipper_width/2) segment_with_square_nuts(anchor=LEFT, orient=FRONT, length = base_zipper_length, height = base_zipper_width, width = base_plate_height, screw_head_h = 5, screw_head_d = 8.5, screw_d = 5, nut_height = 8.5, nut_width = 3);
}

module base_plate_part2(base_plate_part_length, base_plate_height, base_zipper_length, base_zipper_width, pipe_hose_height) {
    diff(remove="hose_pipe_bearing_hole", keep="hose_pipe_bearing")
        cuboid([base_plate_part_length, base_plate_part_length, base_plate_height]) {
            tag("hose_pipe_bearing_hole") right(base_plate_part_length/2-base_plate_pipe_hose_out_d/2) back(base_plate_part_length/2-base_plate_pipe_hose_out_d/2) align(TOP,overlap=base_plate_height/2) zcyl(d=pipe_bearing_inner_diameter+1, h=pipe_hose_height+eps, chamfer=-1)
            tag("") zcyl(d1=base_plate_pipe_hose_out_d, d2=base_plate_pipe_hose_out_d*3/4, h=pipe_hose_height);
            tag("") align(TOP, FRONT+LEFT) prismoid(size1=[claw_height,claw_height], size2=[0,0], h=claw_height, shift=[-claw_height/2,-claw_height/2]);
        }

    fwd(base_plate_part_length/2+base_zipper_width/2-eps) xcopies(n=2, spacing=base_zipper_length) segment_compliment_with_bolts(orient=BACK, length = base_zipper_length, height = base_zipper_width, width = base_plate_height, screw_head_h = 5, screw_head_d = 8.5, screw_d = 5, nut_height = 8.5, nut_width = 3);
    ycopies(n=2, spacing=base_zipper_length) back(base_zipper_length/2) left(base_plate_part_length/2-eps)zrot(-90) back(-base_zipper_width/2)segment_compliment_with_bolts(anchor=LEFT, orient=BACK, length = base_zipper_length, height = base_zipper_width, width = base_plate_height, screw_head_h = 5, screw_head_d = 8.5, screw_d = 5, nut_height = 8, nut_width = 3);
}