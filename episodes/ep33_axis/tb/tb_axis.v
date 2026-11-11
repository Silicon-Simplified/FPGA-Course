// Episode 33 - a source -> axis_add -> sink chain under four traffic patterns, each run with the correct stage and with the planted bug (HOLD = 0).
// The sink checks every word (data = index + K, tlast on every 16th) and a protocol monitor checks the AXI-Stream rule:
// once tvalid is high and tready is low, tvalid, tdata and tlast must not change until the transfer happens.
`timescale 1ns/1ps
module scen #(parameter PV = 16, PR = 16, HOLD = 1, SEED = 16'hACE1, N = 4096, K = 7) (
    input wire clk, output reg done,
    output integer got, errs, viol, span
);
    reg [15:0] lf = SEED;
    always @(posedge clk) lf <= {lf[14:0], lf[15] ^ lf[13] ^ lf[12] ^ lf[10]};
    reg  aresetn = 0;
    reg  s_valid = 0, s_last = 0; reg [31:0] s_data = 0; wire s_ready;
    wire m_valid, m_last; wire [31:0] m_data; reg m_ready = 0;
    axis_add #(K, HOLD) dut (.aclk(clk), .aresetn(aresetn), .s_axis_tdata(s_data), .s_axis_tvalid(s_valid), .s_axis_tready(s_ready), .s_axis_tlast(s_last),
                             .m_axis_tdata(m_data), .m_axis_tvalid(m_valid), .m_axis_tready(m_ready), .m_axis_tlast(m_last));
    // source: holds each word until it is accepted; offers a new one with probability PV/16
    integer i = 0;
    wire acc = s_valid && s_ready;
    wire [31:0] nxt = acc ? i + 1 : i;
    always @(posedge clk) if (aresetn) begin
        if (acc) i <= i + 1;
        if (!s_valid || s_ready) begin s_valid <= (nxt < N) && (lf[3:0] < PV); s_data <= nxt; s_last <= (nxt % 16) == 15; end
    end
    // sink: ready with probability PR/16, checks every accepted word
    integer exp = 0, cyc = 0, first = -1, last = 0, tail = 0;
    reg pv = 0; reg [31:0] pd = 0; reg pl = 0;
    initial begin got = 0; errs = 0; viol = 0; span = 0; done = 0; repeat (4) @(posedge clk); aresetn = 1; end
    always @(posedge clk) if (aresetn) begin
        cyc <= cyc + 1;
        m_ready <= (lf[11:8] < PR);
        if (m_valid && m_ready) begin
            if (m_data !== exp + K || m_last !== ((exp % 16) == 15)) errs = errs + 1;
            exp = exp + 1; got = got + 1; if (first < 0) first = cyc; last = cyc;
        end
        if (pv && (!m_valid || m_data !== pd || m_last !== pl)) viol = viol + 1;      // AXI-Stream rule
        pv <= m_valid && !m_ready; pd <= m_data; pl <= m_last;
        if (i >= N) tail <= tail + 1;
        if (tail == 40 && !done) begin done = 1; span = last - first + 1; end
    end
endmodule

module tb_axis;
    reg clk = 0; always #4 clk = ~clk;
    localparam NS = 4;
    wire [NS-1:0] d_ok, d_bad; integer g_ok [0:NS-1], g_bad [0:NS-1];
    wire [31:0] go0, go1, go2, go3, gb0, gb1, gb2, gb3, eo0, eo1, eo2, eo3, eb0, eb1, eb2, eb3, vo0, vo1, vo2, vo3, vb0, vb1, vb2, vb3, so0, so1, so2, so3;
    // (valid prob, ready prob) in 1/16:  A 16/16 (always)  B 8/8 (half and half)  C 16/4 (slow sink)  D 4/16 (slow source)
    scen #(16, 16, 1, 16'hACE1) ia_ok (clk, d_ok[0], go0, eo0, vo0, so0);   scen #(16, 16, 0, 16'hACE1) ia_bad (clk, d_bad[0], gb0, eb0, vb0, );
    scen #( 8,  8, 1, 16'hBEEF) ib_ok (clk, d_ok[1], go1, eo1, vo1, so1);   scen #( 8,  8, 0, 16'hBEEF) ib_bad (clk, d_bad[1], gb1, eb1, vb1, );
    scen #(16,  4, 1, 16'h1234) ic_ok (clk, d_ok[2], go2, eo2, vo2, so2);   scen #(16,  4, 0, 16'h1234) ic_bad (clk, d_bad[2], gb2, eb2, vb2, );
    scen #( 4, 16, 1, 16'h9876) id_ok (clk, d_ok[3], go3, eo3, vo3, so3);   scen #( 4, 16, 0, 16'h9876) id_bad (clk, d_bad[3], gb3, eb3, vb3, );
    initial begin
        wait (&d_ok && &d_bad);
        $display("AXIS A (always valid, always ready): %0d of 4096 words, %0d errors, %0d protocol violations; %0d words in %0d clocks", go0, eo0, vo0, go0, so0);
        $display("AXIS B (valid 50%%, ready 50%%): %0d of 4096 words, %0d errors, %0d protocol violations; %0d words in %0d clocks", go1, eo1, vo1, go1, so1);
        $display("AXIS C (valid 100%%, ready 25%%): %0d of 4096 words, %0d errors, %0d protocol violations; %0d words in %0d clocks", go2, eo2, vo2, go2, so2);
        $display("AXIS D (valid 25%%, ready 100%%): %0d of 4096 words, %0d errors, %0d protocol violations; %0d words in %0d clocks", go3, eo3, vo3, go3, so3);
        $display("AXIS bug (tready always 1) A: %0d of 4096 words, %0d errors, %0d protocol violations", gb0, eb0, vb0);
        $display("AXIS bug (tready always 1) B: %0d of 4096 words, %0d errors, %0d protocol violations", gb1, eb1, vb1);
        $display("AXIS bug (tready always 1) C: %0d of 4096 words, %0d errors, %0d protocol violations", gb2, eb2, vb2);
        $display("AXIS bug (tready always 1) D: %0d of 4096 words, %0d errors, %0d protocol violations", gb3, eb3, vb3);
        $finish;
    end
endmodule
