// Silicon Simplified - FPGA Course, Episode 1
// Any logic function of up to 6 inputs fits in ONE 6-input LUT.
// Synthesize with scripts/synth.tcl and check the utilization report: Slice LUTs = 1.
`timescale 1ns / 1ps
module any_function (
    input  wire a,
    input  wire b,
    input  wire c,
    input  wire d,
    output wire y
);
    // (A AND B) OR (C XOR D)
    assign y = (a & b) | (c ^ d);
endmodule
