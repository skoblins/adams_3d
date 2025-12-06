include <variants-reed-pipe.scad>

variants_pipe_len = 180;
variants_pipe_in_d = 8;
//variants_pipe_thickness_top = 4;
//variants_pipe_thickness_bottom = 10;
variants_pipe_thickness_top = 4;
variants_pipe_thickness_bottom = 8;
variants_pipe_bottom_d = variants_pipe_in_d + 2 * variants_pipe_thickness_bottom;
variants_pipe_plug_in_d = 18;
variants_pipe_plug_out_d = 20;
variants_pipe_plug_stopper_d = 30;
reed_socket_len = variants_reed_pipe_end_length;
pipe_plug_len=25;
horn_plug_len=13;
horn_plug_in_d = 13.5;
horn_plug_out_d = 20;
horn_pos = -horn_plug_len;

//9
variants_pipe_holes=[
                        // 9b
                         [0.1075, 7/variants_reed_pipe_in_diameter], // d
                        // 9 a
                        //[0.105, 7/variants_reed_pipe_in_diameter], // d
                        [0.233, 8/variants_reed_pipe_in_diameter],  // e
                        [0.365, 6/variants_reed_pipe_in_diameter],  // f
                        [0.43, 6/variants_reed_pipe_in_diameter],  // f#
                        [0.5, 7/variants_reed_pipe_in_diameter], // g
                        [0.68, 7/variants_reed_pipe_in_diameter],  // a
                        [/*0.725*/0.77, 6/variants_reed_pipe_in_diameter], // b / h
                        [0.865, 6/variants_reed_pipe_in_diameter], // c
                        [0.94, 6/variants_reed_pipe_in_diameter],  // d
];

// 8          
//variants_pipe_holes=[
//                        // 8b
//                         [0.1075, 7/variants_reed_pipe_in_diameter], // d
//                        // 8 a
//                        //[0.105, 7/variants_reed_pipe_in_diameter], // d
//                        [0.233, 8/variants_reed_pipe_in_diameter],  // e
//                        [0.365, 6/variants_reed_pipe_in_diameter],  // f
//                        [0.43, 6/variants_reed_pipe_in_diameter],  // f#
//                        [0.5, 7/variants_reed_pipe_in_diameter], // g
//                        [0.68, 7/variants_reed_pipe_in_diameter],  // a
//                        [/*0.725*/0.78, 6/variants_reed_pipe_in_diameter], // b / h
//                        [0.89, 5/variants_reed_pipe_in_diameter], // c
//                        [0.94, 6/variants_reed_pipe_in_diameter],  // d
//]
// 7 majorowa, odrobinę za niskie d
//variants_pipe_holes=[
//                         [0.10, 7/variants_reed_pipe_in_diameter], // d
//                        [0.233, 8/variants_reed_pipe_in_diameter],  // e
//                        [0.365, 6/variants_reed_pipe_in_diameter],  // f
//                        [0.43, 6/variants_reed_pipe_in_diameter],  // f#
//                        [0.5, 7/variants_reed_pipe_in_diameter], // g
//                        [0.68, 7/variants_reed_pipe_in_diameter],  // a
//                        [/*0.725*/0.78, 6/variants_reed_pipe_in_diameter], // b / h
//                        [0.89, 5/variants_reed_pipe_in_diameter], // c
//                        [0.94, 6/variants_reed_pipe_in_diameter],  // d
//                    ];
// 6
//variants_pipe_holes=[
//                         [0.095, 7/variants_reed_pipe_in_diameter], // d
//                        [0.23, 8/variants_reed_pipe_in_diameter],  // e
//                        [0.36, 6/variants_reed_pipe_in_diameter],  // f
//                        [0.43, 6/variants_reed_pipe_in_diameter],  // f#
//                        [0.5, 7/variants_reed_pipe_in_diameter], // g
//                        [0.68, 7/variants_reed_pipe_in_diameter],  // a
//                        [/*0.725*/0.78, 6/variants_reed_pipe_in_diameter], // b / h
//                        [0.89, 5/variants_reed_pipe_in_diameter], // c
//                        [0.94, 6/variants_reed_pipe_in_diameter],  // d
//                    ];
                    
// 5
//variants_pipe_holes=[
//                         [0.095, 8/variants_reed_pipe_in_diameter], // d
//                        [0.23, 8/variants_reed_pipe_in_diameter],  // e
//                        [0.36, 6/variants_reed_pipe_in_diameter],  // f
//                        [0.4, 6/variants_reed_pipe_in_diameter],  // f#
//                        [0.5, 7/variants_reed_pipe_in_diameter], // g
//                        [0.68, 7/variants_reed_pipe_in_diameter],  // a
//                        [/*0.725*/0.78, 6/variants_reed_pipe_in_diameter], // b / h
//                        [0.89, 6/variants_reed_pipe_in_diameter], // c
//                        [0.94, 6/variants_reed_pipe_in_diameter],  // d
//                    ];
// 4  
//variants_pipe_holes=[
//                         [0.095, 7/variants_reed_pipe_in_diameter], // d
//                        [0.23, 8/variants_reed_pipe_in_diameter],  // e
//                        [0.36, 6/variants_reed_pipe_in_diameter],  // f
//                        [0.4, 6/variants_reed_pipe_in_diameter],  // f#
//                        [0.5, 7/variants_reed_pipe_in_diameter], // g
//                        [0.68, 7/variants_reed_pipe_in_diameter],  // a
//                        [/*0.725*/0.8, 6/variants_reed_pipe_in_diameter], // b / h
//                        [0.9, 5/variants_reed_pipe_in_diameter], // c
//                        [0.95, 5/variants_reed_pipe_in_diameter],  // d
//                    ];

variants_breath_pipe_len = 60;
