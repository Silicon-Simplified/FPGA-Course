// 7-input function = two 6-input LUTs + one MUXF7 (the slice's built-in wide multiplexer).
`timescale 1ns / 1ps
module wide7 (
    input  wire [6:0] x,
    output wire       y
);
    wire [5:0] a  = x[5:0];
    wire       f0 = ^a;                                  // depends on all six inputs
    wire       f1 = (a[0] & a[1]) | (a[2] & a[3]) | (a[4] & a[5]);
    assign y = x[6] ? f1 : f0;
endmodule
