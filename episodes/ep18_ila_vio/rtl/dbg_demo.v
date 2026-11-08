// Episode 18 - something worth watching: a free-running 32-bit counter that drives the LEDs, with the counter marked for debug.
module dbg_demo (input wire clk, input wire btn, output wire [3:0] led);
    (* ASYNC_REG = "TRUE" *) reg b1 = 0, b2 = 0;
    always @(posedge clk) begin b1 <= btn; b2 <= b1; end
    (* mark_debug = "true" *) reg [31:0] cnt = 0;
    always @(posedge clk) cnt <= b2 ? 32'd0 : cnt + 32'd1;
    assign led = cnt[27:24];
endmodule
