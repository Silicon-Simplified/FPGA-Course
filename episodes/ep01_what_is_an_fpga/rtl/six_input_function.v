// Silicon Simplified - FPGA Course, Episode 1
// A 6-input function that depends on every input: still exactly ONE LUT6.
`timescale 1ns / 1ps
module six_input_function (
    input  wire [5:0] x,
    output wire       y
);
    assign y = (x[0] & x[1]) ^ (x[2] | x[3]) ^ (x[4] & ~x[5]);
endmodule
