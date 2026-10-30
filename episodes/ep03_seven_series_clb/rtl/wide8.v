// 8-input function = four 6-input LUTs + two MUXF7 + one MUXF8, all inside one slice (no general routing).
`timescale 1ns / 1ps
module wide8 (
    input  wire [7:0] x,
    output wire       y
);
    wire [5:0] a  = x[5:0];
    wire       g0 = ^a;
    wire       g1 = (a[0] & a[1]) | (a[2] & a[3]) | (a[4] & a[5]);
    wire       g2 = (a[0] | a[1]) & (a[2] | a[3]) & (a[4] | a[5]);
    wire       g3 = (a[0] & a[2] & a[4]) | (a[1] & a[3] & a[5]);
    assign y = x[7] ? (x[6] ? g3 : g2) : (x[6] ? g1 : g0);
endmodule
