// Two always blocks driving the same reg: no single piece of hardware can do that.
`timescale 1ns / 1ps
module multi_driver (input wire clk, a, b, output reg q);
    always @(posedge clk) q <= a;
    always @(posedge clk) q <= b;
endmodule
