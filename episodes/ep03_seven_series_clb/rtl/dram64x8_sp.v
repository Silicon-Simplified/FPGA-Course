// SINGLE-port 64 x 8 distributed RAM: one address for write and read -> one LUT (RAM64X1S) per bit.
`timescale 1ns / 1ps
module dram64x8_sp (
    input  wire       clk,
    input  wire       we,
    input  wire [5:0] a,
    input  wire [7:0] d,
    output wire [7:0] q
);
    (* ram_style = "distributed" *) reg [7:0] mem [0:63];
    always @(posedge clk) if (we) mem[a] <= d;
    assign q = mem[a];
endmodule
