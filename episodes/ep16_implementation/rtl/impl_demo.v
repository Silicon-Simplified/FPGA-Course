// Episode 16 - a design big enough for the implementation steps to matter: eight 32-bit words are summed by an adder tree and registered.
// One input bit feeds a 256-bit shift register, so the design needs only three pins (out-of-context synthesis needs none).
module impl_demo (input wire clk, input wire din, output wire dout);
    reg [255:0] sh = 0;
    always @(posedge clk) sh <= {sh[254:0], din};
    reg [34:0] sum = 0;
    always @(posedge clk)
        sum <= sh[31:0] + sh[63:32] + sh[95:64] + sh[127:96] + sh[159:128] + sh[191:160] + sh[223:192] + sh[255:224];
    reg x = 0;
    always @(posedge clk) x <= ^sum;
    assign dout = x;
endmodule
