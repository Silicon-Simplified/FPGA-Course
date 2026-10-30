// The same AND function twice: combinational (follows its inputs at once) and registered (updates only on a clock edge).
`timescale 1ns / 1ps
module comb_vs_seq (
    input  wire clk,
    input  wire a, b,
    output wire y_comb,
    output reg  y_reg
);
    assign y_comb = a & b;
    always @(posedge clk) y_reg <= a & b;
endmodule
