// ...the same three assigns in the REVERSE order: identical hardware, because assigns are wires, not steps.
`timescale 1ns / 1ps
module order_b (input wire a, b, c, d, output wire y);
    wire t1, t2;
    assign y  = t1 | t2;
    assign t2 = c ^ d;
    assign t1 = a & b;
endmodule
