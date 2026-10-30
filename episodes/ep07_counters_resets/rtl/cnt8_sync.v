// Silicon Simplified - FPGA Course, Episode 7
// 8-bit counter, SYNCHRONOUS reset + clock enable.
`timescale 1ns / 1ps
module cnt8_sync (
    input  wire       clk,
    input  wire       rst,
    input  wire       en,
    output reg  [7:0] q
);
    always @(posedge clk) begin
        if (rst)     q <= 8'd0;
        else if (en) q <= q + 8'd1;
    end
endmodule
