// Episode 24 - the same crossings, done properly.
module cdc_good (input wire clk, output wire [3:0] led);
    wire clk_a, clk_b;
    clk_gen g (.clk(clk), .clk_a(clk_a), .clk_b(clk_b));
    reg [7:0] cnt_a = 0;
    always @(posedge clk_a) cnt_a <= cnt_a + 8'd1;
    // 1-bit level: two flip-flops
    wire flag_b;
    sync2 s1 (.clk(clk_b), .d(cnt_a[7]), .q(flag_b));
    // 8-bit counter: Gray code + a synchronizer per bit, back to binary in clk_b
    wire [7:0] gray_a; bin2gray #(8) e (.b(cnt_a), .g(gray_a));
    reg [7:0] gray_q = 0; always @(posedge clk_a) gray_q <= gray_a;
    wire [7:0] gray_b;
    genvar i;
    generate for (i = 0; i < 8; i = i + 1) begin : gs sync2 s (.clk(clk_b), .d(gray_q[i]), .q(gray_b[i])); end endgenerate
    wire [7:0] bus_b; gray2bin #(8) d (.g(gray_b), .b(bus_b));
    // a one-cycle pulse
    reg pa = 0; always @(posedge clk_a) pa <= (cnt_a == 8'd0);
    wire pb; pulse_sync ps (.clk_a(clk_a), .pulse_a(pa), .clk_b(clk_b), .pulse_b(pb));
    // an async FIFO: write the counter whenever not full, read whenever not empty
    wire full, empty; wire [7:0] fo;
    async_fifo #(8, 4) f (.wclk(clk_a), .winc(1'b1), .wdata(cnt_a), .wfull(full), .rclk(clk_b), .rinc(1'b1), .rdata(fo), .rempty(empty));
    assign led = {flag_b, bus_b[7] ^ pb, bus_b[0], fo[0] ^ empty};
endmodule
