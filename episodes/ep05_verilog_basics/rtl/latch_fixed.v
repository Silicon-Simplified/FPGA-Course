// The fix: every path through the block assigns every output.
`timescale 1ns / 1ps
module latch_fixed (
    input  wire       en,
    input  wire [3:0] d,
    output reg  [3:0] q
);
    always @(*) begin
        q = 4'b0000;            // default value first
        if (en) q = d;
    end
endmodule
