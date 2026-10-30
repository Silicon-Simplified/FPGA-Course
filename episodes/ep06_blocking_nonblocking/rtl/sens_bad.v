// Incomplete sensitivity list: the SIMULATOR only re-evaluates when `a` changes, the SYNTHESIZER ignores the list.
`timescale 1ns / 1ps
module sens_bad (input wire a, b, output reg y);
    always @(a) y = a & b;
endmodule
