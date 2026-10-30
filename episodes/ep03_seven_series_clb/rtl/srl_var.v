// Variable-length delay: the 5-bit address picks the tap, so one LUT gives any delay from 1 to 32 clocks.
`timescale 1ns / 1ps
module srl_var (
    input  wire       clk,
    input  wire       ce,
    input  wire       d,
    input  wire [4:0] tap,
    output wire       q
);
    reg [31:0] sh;
    always @(posedge clk) if (ce) sh <= {sh[30:0], d};
    assign q = sh[tap];
endmodule
