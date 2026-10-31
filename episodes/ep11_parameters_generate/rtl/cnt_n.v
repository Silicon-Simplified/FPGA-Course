// Silicon Simplified - FPGA Course, Episode 11
// ONE counter, any width: the width is a PARAMETER.
`timescale 1ns / 1ps
module cnt_n #(parameter W = 8) (
    input  wire         clk,
    input  wire         rst,
    input  wire         en,
    output reg  [W-1:0] q
);
    always @(posedge clk) begin
        if (rst)     q <= {W{1'b0}};
        else if (en) q <= q + 1'b1;
    end
endmodule
