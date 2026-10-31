// Silicon Simplified - FPGA Course, Episode 9
// The same adder, but only ONE pipeline stage: a latency bug. The values are right, they just arrive a clock too early.
`timescale 1ns / 1ps
module add_pipe_bad (input wire clk, input wire [7:0] a, input wire [7:0] b, output reg [8:0] y);
    always @(posedge clk) y <= a + b;
endmodule
