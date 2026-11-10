// Episode 28 - one 16 x 16 signed multiplier, written with 0..3 pipeline stages, plus a MAC, a pre-adder version, and a LUT-only version.
module m0 (input wire clk, input wire signed [15:0] a, b, output wire signed [31:0] p);          // no registers
    assign p = a * b;
endmodule
module m1 (input wire clk, input wire signed [15:0] a, b, output reg signed [31:0] p);           // P register
    always @(posedge clk) p <= a * b;
endmodule
module m2 (input wire clk, input wire signed [15:0] a, b, output reg signed [31:0] p);           // M + P registers
    reg signed [31:0] m;
    always @(posedge clk) begin m <= a * b; p <= m; end
endmodule
module m3 (input wire clk, input wire signed [15:0] a, b, output reg signed [31:0] p);           // A, B, M, P registers (the full DSP48 pipeline)
    reg signed [15:0] ar, br; reg signed [31:0] m;
    always @(posedge clk) begin ar <= a; br <= b; m <= ar * br; p <= m; end
endmodule
module mac (input wire clk, input wire signed [15:0] a, b, input wire clr, output reg signed [39:0] acc);   // multiply-accumulate
    reg signed [15:0] ar, br; reg signed [31:0] m; reg clr_r, clr_m;
    always @(posedge clk) begin ar <= a; br <= b; m <= ar * br; clr_r <= clr; clr_m <= clr_r; acc <= clr_m ? m : acc + m; end
endmodule
module preadd (input wire clk, input wire signed [15:0] a, d, b, output reg signed [32:0] p);   // (a + d) * b  with the DSP48's pre-adder
    reg signed [15:0] ar, dr, br; reg signed [16:0] ad; reg signed [32:0] m;
    always @(posedge clk) begin ar <= a; dr <= d; br <= b; ad <= ar + dr; m <= ad * br; p <= m; end
endmodule
(* use_dsp = "no" *)
module m3_lut (input wire clk, input wire signed [15:0] a, b, output reg signed [31:0] p);       // the same pipeline, DSPs forbidden
    reg signed [15:0] ar, br; reg signed [31:0] m;
    always @(posedge clk) begin ar <= a; br <= b; m <= ar * br; p <= m; end
endmodule
