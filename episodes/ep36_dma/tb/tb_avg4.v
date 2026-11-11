// Episode 36 - the accelerator between a source and a sink: packets of 64 words, signed samples, checked against an independent model of the moving average.
// Patterns (valid / ready in 1/16): A 16/16, B 8/8, C 16/4 (slow sink), D 4/16 (slow source). MUT: 0 correct, 1 history not cleared at TLAST, 2 tready always 1.
`timescale 1ns/1ps
module scen #(parameter PV = 16, PR = 16, MUT = 0, SEED = 16'hACE1, N = 4096) (
    input wire clk, output reg done, output integer got, errs, lasts_bad, span
);
    reg [15:0] lf = SEED;
    always @(posedge clk) lf <= {lf[14:0], lf[15] ^ lf[13] ^ lf[12] ^ lf[10]};
    function signed [31:0] f(input integer i);                    // the i-th input sample: a deterministic signed pseudo-random value
        reg [31:0] z; begin z = i * 32'h9E3779B1; f = $signed(z) >>> 12; end
    endfunction
    reg aresetn = 0, s_valid = 0, s_last = 0; reg [31:0] s_data = 0; wire s_ready, m_valid, m_last; wire [31:0] m_data; reg m_ready = 0;
    axis_avg4 #((MUT == 1) ? 0 : 1, (MUT == 2) ? 0 : 1) dut (.aclk(clk), .aresetn(aresetn), .s_axis_tdata(s_data), .s_axis_tvalid(s_valid), .s_axis_tready(s_ready), .s_axis_tlast(s_last),
                                                              .m_axis_tdata(m_data), .m_axis_tvalid(m_valid), .m_axis_tready(m_ready), .m_axis_tlast(m_last));
    integer i = 0; wire acc = s_valid && s_ready; wire integer nxt = acc ? i + 1 : i;
    always @(posedge clk) if (aresetn) begin
        if (acc) i <= i + 1;
        if (!s_valid || s_ready) begin s_valid <= (nxt < N) && (lf[3:0] < PV); s_data <= f(nxt); s_last <= (nxt % 64) == 63; end
    end
    integer exp = 0, cyc = 0, first = -1, last = 0, tail = 0;
    reg signed [33:0] x, h1 = 0, h2 = 0, h3 = 0, y;
    initial begin got = 0; errs = 0; lasts_bad = 0; span = 0; done = 0; repeat (4) @(posedge clk); aresetn = 1; end
    always @(posedge clk) if (aresetn) begin
        cyc <= cyc + 1;
        m_ready <= (lf[11:8] < PR);
        if (m_valid && m_ready) begin
            x = f(exp); y = (x + h1 + h2 + h3) >>> 2;                       // independent model
            if (m_data !== y[31:0]) errs = errs + 1;
            if (m_last !== ((exp % 64) == 63)) lasts_bad = lasts_bad + 1;
            if ((exp % 64) == 63) begin h1 = 0; h2 = 0; h3 = 0; end else begin h3 = h2; h2 = h1; h1 = x; end
            exp = exp + 1; got = got + 1; if (first < 0) first = cyc; last = cyc;
        end
        if (i >= N) tail <= tail + 1;
        if (tail == 40 && !done) begin done = 1; span = last - first + 1; end
    end
endmodule

module tb_avg4;
    reg clk = 0; always #5 clk = ~clk;
    wire [5:0] d; wire [31:0] g0, g1, g2, g3, g4, g5, e0, e1, e2, e3, e4, e5, l0, l1, l2, l3, l4, l5, s0, s1, s2, s3;
    scen #(16, 16, 0, 16'hACE1) ia (clk, d[0], g0, e0, l0, s0);
    scen #( 8,  8, 0, 16'hBEEF) ib (clk, d[1], g1, e1, l1, s1);
    scen #(16,  4, 0, 16'h1234) ic (clk, d[2], g2, e2, l2, s2);
    scen #( 4, 16, 0, 16'h9876) id (clk, d[3], g3, e3, l3, s3);
    scen #( 8,  8, 1, 16'hBEEF) ie (clk, d[4], g4, e4, l4, );
    scen #( 8,  8, 2, 16'hBEEF) ig (clk, d[5], g5, e5, l5, );
    initial begin
        wait (&d);
        $display("AVG A (always/always): %0d of 4096 words, %0d wrong values, %0d wrong TLAST; %0d words in %0d clocks", g0, e0, l0, g0, s0);
        $display("AVG B (50%%/50%%): %0d of 4096 words, %0d wrong values, %0d wrong TLAST; %0d words in %0d clocks", g1, e1, l1, g1, s1);
        $display("AVG C (slow sink 25%%): %0d of 4096 words, %0d wrong values, %0d wrong TLAST; %0d words in %0d clocks", g2, e2, l2, g2, s2);
        $display("AVG D (slow source 25%%): %0d of 4096 words, %0d wrong values, %0d wrong TLAST; %0d words in %0d clocks", g3, e3, l3, g3, s3);
        $display("AVG bug (history kept across packets) B: %0d of 4096 words, %0d wrong values, %0d wrong TLAST", g4, e4, l4);
        $display("AVG bug (tready always 1) B: %0d of 4096 words, %0d wrong values, %0d wrong TLAST", g5, e5, l5);
        $finish;
    end
endmodule
