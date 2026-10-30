// Silicon Simplified - FPGA Course, Episode 6
// The standard clocked template: synchronous reset + clock enable, non-blocking assignments.
`timescale 1ns / 1ps
module reg8_en_rst (
    input  wire       clk,
    input  wire       rst,
    input  wire       en,
    input  wire [7:0] d,
    output reg  [7:0] q
);
    always @(posedge clk) begin
        if (rst)     q <= 8'h00;
        else if (en) q <= d;
    end
endmodule
