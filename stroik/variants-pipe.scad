include <variants-reed-pipe.scad>

variants_pipe_len = 200;
variants_pipe_in_d = 8;
variants_pipe_thickness_bottom = 10;
variants_pipe_thickness_top = 3;
variants_pipe_plug_in_d = 13;
reed_socket_len = variants_reed_pipe_end_length;
pipe_plug_len=25;
horn_plug_len=15;
horn_plug_in_d = 13;
horn_plug_out_d = 15;
horn_len = 60;
horn_d_out_end = 60;
horn_pos = -horn_plug_len;

variants_pipe_holes=[
                        [0.12125, 8/variants_reed_pipe_in_diameter],
                        [0.2425, 8/variants_reed_pipe_in_diameter],
                        [0.36375, 8/variants_reed_pipe_in_diameter],
                        [0.424375, 8/variants_reed_pipe_in_diameter],
                        [0.485, 8/variants_reed_pipe_in_diameter],
                        [0.60625, 8/variants_reed_pipe_in_diameter],
                        [0.7275, 8/variants_reed_pipe_in_diameter],
                        [0.84875, 8/variants_reed_pipe_in_diameter],
                        [0.97, 8/variants_reed_pipe_in_diameter],
                    ];
