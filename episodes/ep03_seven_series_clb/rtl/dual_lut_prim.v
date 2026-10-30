// The same two functions as dual_lut, but with the LUT6_2 primitive instantiated directly:
// O5 = INIT[31:0] (y1) and O6 = INIT[63:32] with I5 tied high (y2).  One physical LUT, two outputs.
`timescale 1ns / 1ps
module dual_lut_prim (
    input  wire [4:0] x,
    output wire       y1,
    output wire       y2
);
    LUT6_2 #(.INIT(64'h5A48FF4888877778)) u (
        .I0(x[0]), .I1(x[1]), .I2(x[2]), .I3(x[3]), .I4(x[4]), .I5(1'b1),
        .O5(y1), .O6(y2)
    );
endmodule
