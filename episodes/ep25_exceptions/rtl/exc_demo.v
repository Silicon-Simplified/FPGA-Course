// Episode 25 - one design with several things you might be tempted to put an exception on.
//  P1  a quasi-static configuration word (loaded once by a button) feeding a long adder chain   -> false path candidate
//  P2  a slow datapath that is only updated every 2nd clock                                    -> multicycle candidate
//  X   a free-running 250 MHz counter read by a 62.5 MHz register                               -> clock-group candidate
//  G   a Gray-coded pointer crossing into a synchronizer                                         -> set_max_delay -datapath_only candidate
module exc_demo (input wire clk, input wire btn, input wire din, output wire [3:0] led);
    wire clk_a, clk_b;
    clk_gen g (.clk(clk), .clk_a(clk_a), .clk_b(clk_b));          // 250 MHz and 62.5 MHz from one MMCM
    // shared input shift register (125 MHz domain)
    reg [511:0] sh = 0;
    always @(posedge clk) sh <= {sh[510:0], din};
    // P1: p1_cfg is written only when the button is pressed
    reg [31:0] p1_cfg = 0;
    always @(posedge clk) if (btn) p1_cfg <= sh[31:0];
    reg [38:0] p1_dst = 0;
    always @(posedge clk) p1_dst <= p1_cfg + sh[63:32] + sh[95:64] + sh[127:96] + sh[159:128] + sh[191:160] + sh[223:192] + sh[255:224] + sh[287:256] + sh[319:288] + sh[351:320] + sh[383:352] + sh[415:384] + sh[447:416];
    // P2: the source words only change every 2nd clock (enable), the destination is only loaded every 2nd clock
    reg phase = 0;
    always @(posedge clk) phase <= ~phase;
    reg [447:0] p2_src = 0;
    always @(posedge clk) if (phase) p2_src <= sh[447:0];
    reg [38:0] p2_dst = 0;
    always @(posedge clk) if (!phase) p2_dst <= p2_src[31:0] + p2_src[63:32] + p2_src[95:64] + p2_src[127:96] + p2_src[159:128] + p2_src[191:160] + p2_src[223:192] + p2_src[255:224] + p2_src[287:256] + p2_src[319:288] + p2_src[351:320] + p2_src[383:352] + p2_src[415:384] + p2_src[447:416];
    // X: 250 MHz -> 62.5 MHz, no synchronizer (on purpose: this is the clock-group demo)
    reg [7:0] x_cnt = 0;
    always @(posedge clk_a) x_cnt <= x_cnt + 8'd1;
    reg [7:0] x_dst = 0;
    always @(posedge clk_b) x_dst <= x_cnt;
    // G: Gray pointer into a 2-FF synchronizer
    reg [7:0] g_cnt = 0;
    always @(posedge clk_a) g_cnt <= g_cnt + 8'd1;
    reg [7:0] g_gray = 0;
    always @(posedge clk_a) g_gray <= g_cnt ^ (g_cnt >> 1);
    wire [7:0] g_sync;
    genvar i;
    generate for (i = 0; i < 8; i = i + 1) begin : gs sync2 s (.clk(clk_b), .d(g_gray[i]), .q(g_sync[i])); end endgenerate
    assign led = {^p1_dst, ^p2_dst, ^x_dst, ^g_sync};
endmodule
