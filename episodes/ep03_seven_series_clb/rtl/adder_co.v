// Same adder but KEEPING the carry-out as bit W of the result: it costs one extra CARRY4 at the top.
`timescale 1ns / 1ps
module adder_co #(parameter W = 8) (
    input  wire [W-1:0] a,
    input  wire [W-1:0] b,
    output wire [W:0]   s
);
    assign s = a + b;
endmodule
