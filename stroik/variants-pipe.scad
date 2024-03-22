include <variants-reed-pipe.scad>

variants_pipe_len = 200;
variants_pipe_in_d = 8;
variants_pipe_thickness_bottom = 10;
variants_pipe_bottom_d = variants_pipe_in_d + 2 * variants_pipe_thickness_bottom;
variants_pipe_thickness_top = 4;
variants_pipe_plug_in_d = 14;
variants_pipe_plug_out_d = 18;
variants_pipe_plug_stopper_d = 30;
reed_socket_len = variants_reed_pipe_end_length;
pipe_plug_len=25;
horn_plug_len=18;
horn_plug_in_d = 13;
horn_plug_out_d = 15;
horn_len = 85;
horn_d_out_end = 60;
horn_pos = -horn_plug_len;

variants_pipe_holes=[
                        [0.085, 8/variants_reed_pipe_in_diameter],
                        [0.24, 8/variants_reed_pipe_in_diameter],
                        [0.36, 6/variants_reed_pipe_in_diameter],
                        [0.41, 7/variants_reed_pipe_in_diameter],
                        [0.5, 7/variants_reed_pipe_in_diameter],
                        [0.65, 7/variants_reed_pipe_in_diameter],
                        [0.75, 5/variants_reed_pipe_in_diameter],
                        [0.86, 4/variants_reed_pipe_in_diameter],
                        [0.95, 4/variants_reed_pipe_in_diameter],
                    ];

variants_breath_pipe_len = 100;
