// PYNQ-Z2 top level: 11 inputs in, 6 LEDs out.
//   Pmod A: a[3:0] = pins 0-3, b[3:0] = pins 4-7        Pmod B: op[2:0] = pins 0-2
//   LD0-LD3 = result y[3:0], LD4 (green) = zero flag, LD5 (green) = carry
// The PYNQ-Z2 has only 2 switches, so the operands come from the Pmod headers (jumper wire to 3.3 V = 1, to GND = 0, or a Pmod switch module).
`timescale 1ns / 1ps
module alu_top (
    input  wire [3:0] a,
    input  wire [3:0] b,
    input  wire [2:0] op,
    output wire [3:0] led,
    output wire       led_zero,
    output wire       led_carry
);
    wire [3:0] y;
    wire       zero, carry;
    alu4 u_alu (
        .a    (a),
        .b    (b),
        .op   (op),
        .y    (y),
        .zero (zero),
        .carry(carry)
    );
    assign led       = y;
    assign led_zero  = zero;
    assign led_carry = carry;
endmodule
