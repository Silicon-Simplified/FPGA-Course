// Basys 3 top level: 11 switches in, 6 LEDs out.  sw[3:0] = a, sw[7:4] = b, sw[10:8] = op
//                                                  led[3:0] = result, led[4] = zero flag, led[5] = carry
`timescale 1ns / 1ps
module alu_top (
    input  wire [10:0] sw,
    output wire [5:0]  led
);
    wire [3:0] y;
    wire       zero, carry;
    alu4 u_alu (
        .a    (sw[3:0]),
        .b    (sw[7:4]),
        .op   (sw[10:8]),
        .y    (y),
        .zero (zero),
        .carry(carry)
    );
    assign led = {carry, zero, y};
endmodule
