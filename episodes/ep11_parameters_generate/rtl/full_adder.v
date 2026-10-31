`timescale 1ns / 1ps
module full_adder (input wire a, b, cin, output wire s, cout);
    assign s    = a ^ b ^ cin;
    assign cout = (a & b) | (cin & (a ^ b));
endmodule
