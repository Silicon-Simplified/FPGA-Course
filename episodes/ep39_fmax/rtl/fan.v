// Episode 39 - experiment 2: high fanout. One enable drives the clock-enable of 2000 flip-flops.
// fan_plain: the enable register as it is; fan_mf: the same, with MAX_FANOUT = 50 on the enable register (the tool duplicates it).
module fan_plain (input wire clk, input wire en, input wire [1999:0] d, output reg [1999:0] q);
    reg en_r; reg [1999:0] dr;
    always @(posedge clk) begin en_r <= en; dr <= d; if (en_r) q <= dr; end
endmodule
module fan_mf (input wire clk, input wire en, input wire [1999:0] d, output reg [1999:0] q);
    (* max_fanout = 50 *) reg en_r; reg [1999:0] dr;
    always @(posedge clk) begin en_r <= en; dr <= d; if (en_r) q <= dr; end
endmodule
