// Episode 40 - 32 multipliers of 16 x 16 bits, inputs and products registered: in DSP48 slices, or in LUTs.
(* use_dsp = "yes" *)
module mul_dsp (input wire clk, input wire [511:0] a, input wire [511:0] b, output reg [1023:0] p);
    reg [511:0] ar, br; integer i;
    always @(posedge clk) begin ar <= a; br <= b;
        for (i = 0; i < 32; i = i + 1) p[32*i +: 32] <= $signed(ar[16*i +: 16]) * $signed(br[16*i +: 16]); end
endmodule
(* use_dsp = "no" *)
module mul_lut (input wire clk, input wire [511:0] a, input wire [511:0] b, output reg [1023:0] p);
    reg [511:0] ar, br; integer i;
    always @(posedge clk) begin ar <= a; br <= b;
        for (i = 0; i < 32; i = i + 1) p[32*i +: 32] <= $signed(ar[16*i +: 16]) * $signed(br[16*i +: 16]); end
endmodule
