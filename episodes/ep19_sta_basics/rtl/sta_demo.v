// Episode 19 - the smallest design that shows static timing analysis:
//   a_r, b_r  --(16-bit adder)-->  s_r        (a setup-time path through logic)
//   sh1 --> sh2                               (a direct flip-flop to flip-flop path: the hold-time example)
module sta_demo (input wire clk, input wire [15:0] a, b, input wire d, output wire [15:0] s, output wire q);
    reg [15:0] a_r = 0, b_r = 0, s_r = 0;
    reg sh1 = 0, sh2 = 0;
    always @(posedge clk) begin a_r <= a; b_r <= b; s_r <= a_r + b_r; sh1 <= d; sh2 <= sh1; end
    assign s = s_r;
    assign q = sh2;
endmodule
