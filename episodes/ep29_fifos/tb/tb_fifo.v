// Episode 29 - three self-checking experiments on the synchronous FIFOs.
//  A  integrity: 5000 random words with random write/read gaps, standard and first-word-fall-through, compared with a model queue
//  B  read latency: how many clock edges after rd_en does the data appear?
//  C  sizing: a burst of 100 writes at 1 word/clock, the reader takes 1 word every 2 clocks; peak occupancy and dropped writes for depth 32 and 64
`timescale 1ns/1ps
module tb_fifo;
    reg clk = 0; always #5 clk = ~clk;
    reg rst = 1;
    // ---- A
    reg wr = 0, rd = 0; reg [15:0] din = 0;
    wire [15:0] q_std, q_fw; wire f_std, e_std, f_fw, e_fw; wire [4:0] c_std, c_fw;
    sync_fifo_std  #(16, 4) ds (.clk(clk), .rst(rst), .wr_en(wr), .din(din), .rd_en(rd), .dout(q_std), .full(f_std), .empty(e_std), .count(c_std));
    sync_fifo_fwft #(16, 4) df (.clk(clk), .rst(rst), .wr_en(wr), .din(din), .rd_en(rd), .dout(q_fw),  .full(f_fw),  .empty(e_fw),  .count(c_fw));
    reg [15:0] model [0:63]; integer mh = 0, mt = 0, errs = 0, nw = 0, nr = 0;
    reg [31:0] lf = 32'hBEEF_1234;
    reg rd_d = 0; reg [15:0] exp_d = 0;
    always @(posedge clk) if (!rst) begin
        lf <= {lf[30:0], lf[31] ^ lf[21] ^ lf[1] ^ lf[0]};
        // check data requested on the previous clock (standard mode: valid one clock after rd_en)
        if (rd_d) begin if (q_std !== exp_d) errs = errs + 1; end
        rd_d <= 0;
        // fwft check: when we read, the data on the output BEFORE the edge must be the oldest word
        if (rd && !e_fw) begin if (q_fw !== model[mh % 64]) errs = errs + 1; end
        // the DUT sees wr/rd as set before this edge; update the model with the same rule
        if (wr && !f_std) begin model[mt % 64] = din; mt = mt + 1; nw = nw + 1; end
        if (rd && !e_std) begin exp_d = model[mh % 64]; mh = mh + 1; nr = nr + 1; rd_d <= 1; end
        wr <= (lf[1:0] != 0) && (nw < 5000); din <= nw[15:0] * 16'd7 + 16'd3;
        rd <= lf[7] | lf[3];
    end
    // ---- B
    reg wr_b = 0, rd_b = 0; reg [15:0] din_b = 0; wire [15:0] qb_s, qb_f; wire fb1, eb1, fb2, eb2; wire [4:0] cb1, cb2;
    reg rst_b = 1;
    sync_fifo_std  #(16, 4) bs (.clk(clk), .rst(rst_b), .wr_en(wr_b), .din(din_b), .rd_en(rd_b), .dout(qb_s), .full(fb1), .empty(eb1), .count(cb1));
    sync_fifo_fwft #(16, 4) bf (.clk(clk), .rst(rst_b), .wr_en(wr_b), .din(din_b), .rd_en(rd_b), .dout(qb_f), .full(fb2), .empty(eb2), .count(cb2));
    // ---- C
    reg rst_c = 1; reg wr_c = 0, rd_c = 0; reg [15:0] din_c = 0;
    wire [15:0] qc32, qc64; wire fc32, ec32, fc64, ec64; wire [5:0] cc32; wire [6:0] cc64;
    sync_fifo_std #(16, 5) c32 (.clk(clk), .rst(rst_c), .wr_en(wr_c), .din(din_c), .rd_en(rd_c), .dout(qc32), .full(fc32), .empty(ec32), .count(cc32));
    sync_fifo_std #(16, 6) c64 (.clk(clk), .rst(rst_c), .wr_en(wr_c), .din(din_c), .rd_en(rd_c), .dout(qc64), .full(fc64), .empty(ec64), .count(cc64));
    integer occf;
    initial begin occf = $fopen("occupancy.csv", "w"); $fdisplay(occf, "clock,depth32,depth64"); end
    integer pk32 = 0, pk64 = 0, drop32 = 0, drop64 = 0, bc = 0, i;
    always @(posedge clk) if (!rst_c) begin
        bc <= bc + 1;
        wr_c <= (bc < 100); din_c <= bc;
        rd_c <= (bc[0] == 1'b0) && bc > 0;                      // 1 word every 2 clocks
        if (wr_c && fc32) drop32 = drop32 + 1;
        if (wr_c && fc64) drop64 = drop64 + 1;
        $fdisplay(occf, "%0d,%0d,%0d", bc, cc32, cc64);
        if (cc32 > pk32) pk32 = cc32;
        if (cc64 > pk64) pk64 = cc64;
    end
    initial begin
        repeat (4) @(posedge clk); rst <= 0;
        // B: write one word, then read it
        repeat (2) @(posedge clk); rst_b <= 0;
        @(negedge clk); wr_b = 1; din_b = 16'hCAFE; @(negedge clk); wr_b = 0;
        repeat (2) @(negedge clk);
        $display("B before rd_en:      fwft dout=%h (already there, empty=%b)   std dout=%h", qb_f, eb2, qb_s);
        rd_b = 1; @(negedge clk); rd_b = 0;
        $display("B 1 clock after rd_en:  std dout=%h", qb_s);
        // C: start the burst
        repeat (2) @(posedge clk); rst_c <= 0;
        repeat (9000) @(posedge clk);
        $fclose(occf);
        $display("A integrity: %0d words written, %0d read, %0d errors", nw, nr, errs);
        $display("C burst of 100 at 1 word/clk, reader 1 word / 2 clk:  depth 32: peak occupancy %0d, dropped writes %0d   |   depth 64: peak occupancy %0d, dropped writes %0d", pk32, drop32, pk64, drop64);
        $finish;
    end
    initial begin #2000000; $display("TIMEOUT"); $finish; end
endmodule
