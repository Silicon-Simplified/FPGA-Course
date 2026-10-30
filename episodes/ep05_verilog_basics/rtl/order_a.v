// Three assigns, one order...
`timescale 1ns / 1ps
module order_a (input wire a, b, c, d, output wire y);
    wire t1, t2;
    assign t1 = a & b;
    assign t2 = c ^ d;
    assign y  = t1 | t2;
endmodule
