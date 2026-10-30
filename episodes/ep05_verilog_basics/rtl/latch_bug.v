// THE classic beginner bug: an `if` without `else` inside a combinational always block.
// When en = 0 the circuit must "remember" q  ->  the tool builds a LATCH.
`timescale 1ns / 1ps
module latch_bug (
    input  wire       en,
    input  wire [3:0] d,
    output reg  [3:0] q
);
    always @(*) begin
        if (en) q = d;
    end
endmodule
