// Silicon Simplified - FPGA Course, Episode 11
// The same adder written with "+": Vivado infers the dedicated CARRY4 chain.
`timescale 1ns / 1ps
module add_plus #(parameter N = 8) (
    input  wire [N-1:0] a, b,
    output wire [N-1:0] sum,
    output wire         cout
);
    assign {cout, sum} = a + b;
endmodule
