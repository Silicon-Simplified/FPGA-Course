// Episode 22 - the failing design with 3 extra pipeline stage(s): registers after tree level(s) [2, 3, 4].
// 24 x 32-bit words -> balanced adder tree (5 levels) -> sum register -> xor -> dout. Latency = 4 cycles after the shift register.
module pipe_3 (input wire clk, input wire din, output wire dout);
    reg [767:0] sh = 0;
    always @(posedge clk) sh <= {sh[766:0], din};
    wire [36:0] l1_0 = sh[31:0] + sh[63:32];
    wire [36:0] l1_1 = sh[95:64] + sh[127:96];
    wire [36:0] l1_2 = sh[159:128] + sh[191:160];
    wire [36:0] l1_3 = sh[223:192] + sh[255:224];
    wire [36:0] l1_4 = sh[287:256] + sh[319:288];
    wire [36:0] l1_5 = sh[351:320] + sh[383:352];
    wire [36:0] l1_6 = sh[415:384] + sh[447:416];
    wire [36:0] l1_7 = sh[479:448] + sh[511:480];
    wire [36:0] l1_8 = sh[543:512] + sh[575:544];
    wire [36:0] l1_9 = sh[607:576] + sh[639:608];
    wire [36:0] l1_10 = sh[671:640] + sh[703:672];
    wire [36:0] l1_11 = sh[735:704] + sh[767:736];
    reg [36:0] l2_0 = 0; always @(posedge clk) l2_0 <= l1_0 + l1_1;
    reg [36:0] l2_1 = 0; always @(posedge clk) l2_1 <= l1_2 + l1_3;
    reg [36:0] l2_2 = 0; always @(posedge clk) l2_2 <= l1_4 + l1_5;
    reg [36:0] l2_3 = 0; always @(posedge clk) l2_3 <= l1_6 + l1_7;
    reg [36:0] l2_4 = 0; always @(posedge clk) l2_4 <= l1_8 + l1_9;
    reg [36:0] l2_5 = 0; always @(posedge clk) l2_5 <= l1_10 + l1_11;
    reg [36:0] l3_0 = 0; always @(posedge clk) l3_0 <= l2_0 + l2_1;
    reg [36:0] l3_1 = 0; always @(posedge clk) l3_1 <= l2_2 + l2_3;
    reg [36:0] l3_2 = 0; always @(posedge clk) l3_2 <= l2_4 + l2_5;
    reg [36:0] l4_0 = 0; always @(posedge clk) l4_0 <= l3_0 + l3_1;
    reg [36:0] l4_1 = 0; always @(posedge clk) l4_1 <= l3_2;
    wire [36:0] l5_0 = l4_0 + l4_1;
    reg [36:0] sum = 0; always @(posedge clk) sum <= l5_0;
    reg x = 0; always @(posedge clk) x <= ^sum;
    assign dout = x;
endmodule
