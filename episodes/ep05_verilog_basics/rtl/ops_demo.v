// Every operator family on one page: bitwise, arithmetic, shift, compare, conditional, concatenate, replicate.
`timescale 1ns / 1ps
module ops_demo (
    input  wire [3:0] a,
    input  wire [3:0] b,
    output wire [3:0] and_o, or_o, xor_o, not_o,
    output wire [3:0] add_o,
    output wire [3:0] shl_o,
    output wire       eq_o,
    output wire [3:0] max_o,
    output wire [7:0] cat_o,
    output wire [3:0] rep_o
);
    assign and_o = a & b;
    assign or_o  = a | b;
    assign xor_o = a ^ b;
    assign not_o = ~a;
    assign add_o = a + b;               // 4-bit result: the carry is dropped
    assign shl_o = a << 1;
    assign eq_o  = (a == b);
    assign max_o = (a > b) ? a : b;     // conditional operator = a multiplexer
    assign cat_o = {a, b};              // concatenation: a on top, b below
    assign rep_o = {2{a[1:0]}};         // replication
endmodule
