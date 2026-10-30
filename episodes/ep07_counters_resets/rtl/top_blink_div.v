`timescale 1ns / 1ps
module top_blink_div (input wire clk, input wire btnC, output wire [3:0] led);
    blink_div #(.N(100_000_000)) u (.clk(clk), .rst(btnC), .led(led));
endmodule
