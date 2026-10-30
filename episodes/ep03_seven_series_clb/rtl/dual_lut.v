// Silicon Simplified - FPGA Course, Episode 3
// Two different 5-input functions that SHARE their inputs: a LUT6 can act as two LUT5s (outputs O5 and O6).
`timescale 1ns / 1ps
module dual_lut (
    input  wire [4:0] x,
    output wire       y1,
    output wire       y2
);
    assign y1 = (x[0] & x[1]) ^ (x[2] | x[3]) ^ x[4];
    assign y2 = ((x[0] ^ x[2]) & (x[1] | x[3])) | (~x[4] & x[3]);
endmodule
