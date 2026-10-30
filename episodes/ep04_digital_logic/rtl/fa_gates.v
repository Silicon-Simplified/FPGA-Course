// Silicon Simplified - FPGA Course, Episode 4
// Full adder written as GATES: you decide the structure (two XORs, two ANDs, one OR).
`timescale 1ns / 1ps
module fa_gates (
    input  wire a, b, cin,
    output wire sum, cout
);
    wire x1 = a ^ b;
    wire a1 = a & b;
    wire a2 = x1 & cin;
    assign sum  = x1 ^ cin;
    assign cout = a1 | a2;
endmodule
