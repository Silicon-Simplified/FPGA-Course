// Episode 40 - drives the post-implementation netlist with random data to record switching activity (SAIF). Select the device under test with a define:
//   -d PW=pw_ce | pw_free | pw_gate  (4096-bit random data every clock; en high with probability DUTY %)    -d MUL=mul_dsp | mul_lut    -d DLY=1 (MODE chosen at synthesis)
`timescale 1ns/1ps
`ifndef DUTYV
`define DUTYV 100
`endif
module tb;
    parameter DUTY = `DUTYV;
    reg clk = 0; always #5 clk = ~clk;
    integer i;
`ifdef PW
    reg en = 0; reg [4095:0] d = 0; wire [4095:0] q;
    `PW dut (.clk(clk), .en(en), .d(d), .q(q));
    always @(negedge clk) begin en <= ($urandom % 100) < DUTY; for (i = 0; i < 128; i = i + 1) d[32*i +: 32] <= $urandom; end
`endif
`ifdef MUL
    reg [511:0] a = 0, b = 0; wire [1023:0] p;
    `MUL dut (.clk(clk), .a(a), .b(b), .p(p));
    always @(negedge clk) for (i = 0; i < 16; i = i + 1) begin a[32*i +: 32] <= $urandom; b[32*i +: 32] <= $urandom; end
`endif
`ifdef DLY
    reg rst = 0; reg [31:0] d = 0; wire [31:0] q;
    dly dut (.clk(clk), .rst(rst), .d(d), .q(q));
    always @(negedge clk) d <= $urandom;
`endif
    initial begin #20000; $finish; end            // 2000 clocks
endmodule
