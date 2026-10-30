// The SAME full adder written as BEHAVIOUR: "add three bits". The tool chooses the structure.
`timescale 1ns / 1ps
module fa_rtl (
    input  wire a, b, cin,
    output wire sum, cout
);
    assign {cout, sum} = a + b + cin;
endmodule
