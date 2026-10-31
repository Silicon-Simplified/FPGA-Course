// Silicon Simplified - FPGA Course, Episode 9
// 8-bit adder with a 2-stage pipeline: the result appears 2 clock edges after the inputs.
`timescale 1ns / 1ps
module add_pipe (input wire clk, input wire [7:0] a, input wire [7:0] b, output reg [8:0] y);
    reg [8:0] s1;
    always @(posedge clk) begin
        s1 <= a + b;
        y  <= s1;
    end
endmodule
