// Silicon Simplified - FPGA Course, Episode 7
// The same counter with an ASYNCHRONOUS reset.
`timescale 1ns / 1ps
module cnt8_async (
    input  wire       clk,
    input  wire       rst,
    input  wire       en,
    output reg  [7:0] q
);
    always @(posedge clk or posedge rst) begin
        if (rst)     q <= 8'd0;
        else if (en) q <= q + 8'd1;
    end
endmodule
