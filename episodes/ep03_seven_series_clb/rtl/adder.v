// The "+" operator maps onto the dedicated CARRY4 chain: 4 bits per CARRY4, carry travels on a fast private wire.
`timescale 1ns / 1ps
module adder #(parameter W = 8) (
    input  wire [W-1:0] a,
    input  wire [W-1:0] b,
    output wire [W-1:0] s            // W-bit sum, carry-out dropped
);
    assign s = a + b;
endmodule
