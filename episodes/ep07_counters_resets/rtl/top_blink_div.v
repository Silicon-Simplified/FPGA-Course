`timescale 1ns / 1ps
// PYNQ-Z2: 125 MHz clock -> N = 125,000,000 clocks = 1 second per LED-counter step
module top_blink_div (input wire clk, input wire btn, output wire [3:0] led);
    blink_div #(.N(125_000_000)) u (.clk(clk), .rst(btn), .led(led));
endmodule
