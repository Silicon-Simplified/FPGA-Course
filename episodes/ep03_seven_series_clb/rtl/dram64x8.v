// 64 x 8 memory in LUTs ("distributed RAM"): synchronous write, ASYNCHRONOUS read. Needs SLICEM LUTs.
`timescale 1ns / 1ps
module dram64x8 (
    input  wire       clk,
    input  wire       we,
    input  wire [5:0] wa,
    input  wire [5:0] ra,
    input  wire [7:0] d,
    output wire [7:0] q
);
    (* ram_style = "distributed" *) reg [7:0] mem [0:63];
    always @(posedge clk) if (we) mem[wa] <= d;
    assign q = mem[ra];
endmodule
