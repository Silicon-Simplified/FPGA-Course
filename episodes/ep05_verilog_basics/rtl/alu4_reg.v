// The SAME ALU with its outputs registered: now the `reg`s really are flip-flops, because of @(posedge clk).
`timescale 1ns / 1ps
module alu4_reg (
    input  wire       clk,
    input  wire [3:0] a,
    input  wire [3:0] b,
    input  wire [2:0] op,
    output reg  [3:0] y,
    output reg        zero,
    output reg        carry
);
    wire [3:0] y_c;
    wire       z_c, c_c;
    alu4 u_alu (.a(a), .b(b), .op(op), .y(y_c), .zero(z_c), .carry(c_c));
    always @(posedge clk) begin
        y     <= y_c;
        zero  <= z_c;
        carry <= c_c;
    end
endmodule
