// The same shift register WITH a reset on every bit: a reset forces real flip-flops (no SRL packing).
`timescale 1ns / 1ps
module srl_delay_ff #(parameter DEPTH = 32) (
    input  wire clk,
    input  wire rst,
    input  wire ce,
    input  wire d,
    output wire q
);
    reg [DEPTH-1:0] sh;
    always @(posedge clk) begin
        if (rst)     sh <= {DEPTH{1'b0}};
        else if (ce) sh <= {sh[DEPTH-2:0], d};
    end
    assign q = sh[DEPTH-1];
endmodule
