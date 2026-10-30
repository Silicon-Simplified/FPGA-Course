// The fix: @(*) re-evaluates when ANY input changes. Simulation and hardware now agree.
`timescale 1ns / 1ps
module sens_good (input wire a, b, output reg y);
    always @(*) y = a & b;
endmodule
