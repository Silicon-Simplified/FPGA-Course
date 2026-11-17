// Episode 39 - experiment 4: control sets. 1024 flip-flops. MODE 0: all of them share one clock enable; MODE 1: every group of 4 has its own clock enable (256 control sets).
// Flip-flops in one slice must share clock, clock enable and set/reset, so more control sets means more, emptier slices.
module cs #(parameter MODE = 0) (input wire clk, input wire [255:0] ce, input wire [1023:0] d, output reg [1023:0] q);
    integer g; reg [255:0] cer; reg [1023:0] dr;
    always @(posedge clk) begin cer <= ce; dr <= d; end
    always @(posedge clk) for (g = 0; g < 256; g = g + 1) if ((MODE == 0) ? cer[0] : cer[g]) q[4*g +: 4] <= dr[4*g +: 4];
endmodule
