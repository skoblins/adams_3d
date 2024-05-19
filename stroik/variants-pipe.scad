include <variants-reed-pipe.scad>

variants_pipe_len = 214;
variants_pipe_in_d = 8;
variants_pipe_thickness_top = 4;
variants_pipe_thickness_bottom = 10;
variants_pipe_bottom_d = variants_pipe_in_d + 2 * variants_pipe_thickness_bottom;
variants_pipe_plug_in_d = 15;
variants_pipe_plug_out_d = 19;
variants_pipe_plug_stopper_d = 26;
reed_socket_len = variants_reed_pipe_end_length;
pipe_plug_len=25;
horn_plug_len=13;
horn_plug_in_d = 13;
horn_plug_out_d = 15;
horn_len = 85;
horn_d_out_end = 60;
horn_pos = -horn_plug_len;

variants_pipe_holes=[
                         [0.085, 7/variants_reed_pipe_in_diameter], // d
                        [0.24, 8/variants_reed_pipe_in_diameter],  // e
                        [0.36, 6/variants_reed_pipe_in_diameter],  // f
                        [0.40, 7/variants_reed_pipe_in_diameter],  // f#
                        [0.485, 7/variants_reed_pipe_in_diameter], // g
                        [0.64, 7/variants_reed_pipe_in_diameter],  // a
                        [0.735, 6/variants_reed_pipe_in_diameter], // b
                        [0.84, 5/variants_reed_pipe_in_diameter], // c
                        [0.94, 5/variants_reed_pipe_in_diameter],  // d
                    ];

variants_breath_pipe_len = 55;
