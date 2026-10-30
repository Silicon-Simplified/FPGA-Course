// A DEPTH-bit shift register with no reset: Vivado packs 32 bits into ONE LUT (SRLC32E) inside a SLICEM.
`timescale 1ns / 1ps
module srl_delay #(parameter DEPTH = 32) (
    input  wire clk,
    input  wire ce,
    input  wire d,
    output wire q
);
    reg [DEPTH-1:0] sh;
    always @(posedge clk) if (ce) sh <= {sh[DEPTH-2:0], d};
    assign q = sh[DEPTH-1];
endmodule
