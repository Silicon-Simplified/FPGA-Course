// 4-bit ALU. Eight operations selected by `op`:
//   000 ADD   001 SUB   010 AND   011 OR   100 XOR   101 NOT a   110 SHL a   111 SHR a
// `reg` here does NOT mean a register: this always block is purely combinational.
`timescale 1ns / 1ps
module alu4 (
    input  wire [3:0] a,
    input  wire [3:0] b,
    input  wire [2:0] op,
    output reg  [3:0] y,
    output wire       zero,
    output reg        carry
);
    // hierarchy: one adder4 instance does both ADD and SUB (a - b = a + ~b + 1)
    wire       sub = (op == 3'b001);
    wire [3:0] sum;
    wire       cout;
    adder4 u_add (
        .a   (a),
        .b   (b ^ {4{sub}}),
        .cin (sub),
        .sum (sum),
        .cout(cout)
    );

    always @(*) begin
        carry = 1'b0;
        case (op)
            3'b000:  begin y = sum;      carry = cout; end
            3'b001:  begin y = sum;      carry = cout; end   // carry = 1 means "no borrow" (a >= b)
            3'b010:  y = a & b;
            3'b011:  y = a | b;
            3'b100:  y = a ^ b;
            3'b101:  y = ~a;
            3'b110:  y = a << 1;
            3'b111:  y = a >> 1;
            default: y = 4'b0000;
        endcase
    end

    assign zero = (y == 4'b0000);
endmodule
