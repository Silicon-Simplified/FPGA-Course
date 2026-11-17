// Episode 40 - power experiments. 256 accumulators of 16 bits (4096 flip-flops) fed by 4096 input bits.
// pw_free: always accumulates (no enable);  pw_ce: accumulates when en = 1 (flip-flop clock enable);  pw_gate: the clock itself is gated with a BUFGCE.
module pw_free (input wire clk, input wire en, input wire [4095:0] d, output wire [4095:0] q);
    reg [15:0] a [0:255]; genvar i;
    generate for (i = 0; i < 256; i = i + 1) begin : g
        always @(posedge clk) a[i] <= a[i] + d[16*i +: 16];
        assign q[16*i +: 16] = a[i];
    end endgenerate
endmodule
module pw_ce (input wire clk, input wire en, input wire [4095:0] d, output wire [4095:0] q);
    reg [15:0] a [0:255]; genvar i;
    generate for (i = 0; i < 256; i = i + 1) begin : g
        always @(posedge clk) if (en) a[i] <= a[i] + d[16*i +: 16];
        assign q[16*i +: 16] = a[i];
    end endgenerate
endmodule
module pw_gate (input wire clk, input wire en, input wire [4095:0] d, output wire [4095:0] q);
    wire gclk; BUFGCE bg (.I(clk), .CE(en), .O(gclk));
    reg [15:0] a [0:255]; genvar i;
    generate for (i = 0; i < 256; i = i + 1) begin : g
        always @(posedge gclk) a[i] <= a[i] + d[16*i +: 16];
        assign q[16*i +: 16] = a[i];
    end endgenerate
endmodule
