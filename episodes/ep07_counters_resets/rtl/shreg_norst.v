// Silicon Simplified - FPGA Course, Episode 7
// The same delay line with NO reset on the data path.
`timescale 1ns / 1ps
module shreg_norst (
    input  wire       clk,
    input  wire       rst,   // unused on purpose: data-path registers don't need a reset
    input  wire [7:0] d,
    output wire [7:0] q
);
    reg [7:0] s [0:31];
    integer i;
    always @(posedge clk) begin
        s[0] <= d;
        for (i = 1; i < 32; i = i + 1) s[i] <= s[i-1];
    end
    assign q = s[31];
endmodule
