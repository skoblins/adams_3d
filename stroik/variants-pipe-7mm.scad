include <variants-reed-pipe.scad>

variants_pipe_len = 198;
variants_pipe_in_d = 7;
variants_pipe_thickness_top = 3.5;
variants_pipe_thickness_bottom = 8.75;
variants_pipe_bottom_d = variants_pipe_in_d + 2 * variants_pipe_thickness_bottom;
variants_pipe_plug_in_d = 15;
variants_pipe_plug_out_d = 19;
variants_pipe_plug_stopper_d = 26;
reed_socket_len = variants_reed_pipe_end_length;
pipe_plug_len=25;
horn_plug_len=13;
horn_plug_in_d = 13.5;
horn_plug_out_d = 20;
horn_pos = -horn_plug_len;

variants_pipe_holes=[
                         [0.095, 5/variants_reed_pipe_in_diameter], // d
                        [0.245, 7/variants_reed_pipe_in_diameter],  // e
                        [0.37, 5/variants_reed_pipe_in_diameter],  // f
                        [0.41, 6/variants_reed_pipe_in_diameter],  // f#
                        [0.505, 7/variants_reed_pipe_in_diameter], // g
                        [0.66, 7/variants_reed_pipe_in_diameter],  // a
                        [0.765, 6/variants_reed_pipe_in_diameter], // b / h
                        [0.87, 5/variants_reed_pipe_in_diameter], // c
                        [0.95, 5/variants_reed_pipe_in_diameter],  // d
                    ];

variants_breath_pipe_len = 60;
