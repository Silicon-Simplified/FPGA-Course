// Episode 21 - an intentionally failing design for the PYNQ-Z2's 125 MHz clock (8 ns).
// 24 32-bit words are added in ONE clock cycle (a long adder network), then registered. It is too slow on purpose.
// Episode 22 fixes it step by step.
module fail_demo (input wire clk, input wire din, output wire dout);
    reg [767:0] sh = 0;
    always @(posedge clk) sh <= {sh[766:0], din};
    reg [36:0] sum = 0;
    always @(posedge clk)
        sum <= sh[31:0] + sh[63:32] + sh[95:64] + sh[127:96] + sh[159:128] + sh[191:160] + sh[223:192] + sh[255:224] + sh[287:256] + sh[319:288] + sh[351:320] + sh[383:352] + sh[415:384] + sh[447:416] + sh[479:448] + sh[511:480] + sh[543:512] + sh[575:544] + sh[607:576] + sh[639:608] + sh[671:640] + sh[703:672] + sh[735:704] + sh[767:736];
    reg x = 0;
    always @(posedge clk) x <= ^sum;
    assign dout = x;
endmodule
