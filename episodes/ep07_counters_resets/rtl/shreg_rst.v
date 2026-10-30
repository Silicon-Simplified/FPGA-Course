// Silicon Simplified - FPGA Course, Episode 7
// 8-bit wide, 32-deep delay line where EVERY stage has a synchronous reset.
`timescale 1ns / 1ps
module shreg_rst (
    input  wire       clk,
    input  wire       rst,
    input  wire [7:0] d,
    output wire [7:0] q
);
    reg [7:0] s [0:31];
    integer i;
    always @(posedge clk) begin
        if (rst) begin
            for (i = 0; i < 32; i = i + 1) s[i] <= 8'd0;
        end else begin
            s[0] <= d;
            for (i = 1; i < 32; i = i + 1) s[i] <= s[i-1];
        end
    end
    assign q = s[31];
endmodule
