// Silicon Simplified - FPGA Course, Episode 5
// A small reusable module: 4-bit adder with carry in and carry out.
`timescale 1ns / 1ps
module adder4 (
    input  wire [3:0] a,
    input  wire [3:0] b,
    input  wire       cin,
    output wire [3:0] sum,
    output wire       cout
);
    // make every width explicit: 5-bit operands give a 5-bit result {carry, sum}
    assign {cout, sum} = {1'b0, a} + {1'b0, b} + {4'b0000, cin};
endmodule
