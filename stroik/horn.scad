include <reed/pipe.scad>
include <variants-pipe.scad>

$fn=100;

// l, d_end, thickness, d_sock_in, d_sock_out, l_sock
horn(length=horn_len, d_end=horn_d_out_end, thickness=4, d_sock_in=horn_plug_out_d, d_sock_out=horn_plug_out_d+4, l_sock=horn_plug_len);
