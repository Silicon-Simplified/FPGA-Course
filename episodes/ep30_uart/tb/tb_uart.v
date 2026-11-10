// Episode 30 - self-checking tests: loopback of all 256 byte values, the receiver's baud-rate tolerance, and a break (framing error).
`timescale 1ns/1ps
module tb_uart;
    reg clk = 0; always #4 clk = ~clk;                                  // 125 MHz
    // ---- DUT A: TX -> RX loopback
    wire t16; baud_gen #(125_000_000, 115_200) g (.clk(clk), .tick16(t16));
    reg start = 0; reg [7:0] txd = 0; wire tx, busy;
    uart_tx t (.clk(clk), .tick16(t16), .start(start), .data(txd), .tx(tx), .busy(busy));
    wire [7:0] rd_a; wire v_a, fe_a;
    uart_rx r (.clk(clk), .tick16(t16), .rx(tx), .data(rd_a), .valid(v_a), .frame_err(fe_a));
    // ---- DUT B: receiver driven by a behavioural transmitter with an arbitrary bit period
    reg line = 1; wire [7:0] rd_b; wire v_b, fe_b;
    uart_rx rb (.clk(clk), .tick16(t16), .rx(line), .data(rd_b), .valid(v_b), .frame_err(fe_b));
    integer i, k, errs_a = 0, sent_a = 0, got_a = 0;
    reg [7:0] last_a; reg got_flag = 0;
    always @(posedge clk) if (v_a) begin got_a = got_a + 1; last_a <= rd_a; if (rd_a !== txd) errs_a = errs_a + 1; if (fe_a) errs_a = errs_a + 1; end
    task send_a(input [7:0] b); begin @(negedge clk); txd = b; start = 1; @(negedge clk); start = 0; sent_a = sent_a + 1; wait (busy == 0); repeat (40) @(negedge clk); end endtask
    // behavioural transmitter with bit period bit_ns (real)
    reg [7:0] rx_got; integer rx_cnt;
    always @(posedge clk) if (v_b) begin rx_got <= rd_b; rx_cnt = rx_cnt + 1; end
    task send_b(input [7:0] b, input real bit_ns);
        integer j; begin
            line = 0; #(bit_ns);
            for (j = 0; j < 8; j = j + 1) begin line = b[j]; #(bit_ns); end
            line = 1; #(bit_ns); #(bit_ns);
        end
    endtask
    real nominal = 16.0 * 68.0 * 8.0;                                    // the DUT's own bit time: 16 ticks of 68 clocks of 8 ns = 8704 ns
    real e; integer bad, n; reg [7:0] b;
    initial begin
        repeat (20) @(negedge clk);
        for (i = 0; i < 256; i = i + 1) send_a(i[7:0]);
        $display("LOOPBACK sent=%0d received=%0d errors=%0d", sent_a, got_a, errs_a);
        // tolerance sweep: transmitter bit time = nominal * (1 + e)
        for (k = -9; k <= 9; k = k + 1) begin
            e = k / 100.0; bad = 0; rx_cnt = 0;
            for (n = 0; n < 40; n = n + 1) begin
                b = (n * 37 + 11) & 8'hFF; send_b(b, nominal * (1.0 + e)); repeat (4) @(negedge clk);
                if (rx_got !== b) bad = bad + 1;
            end
            $display("TOL error=%0d%% bad_bytes=%0d of 40", k, bad);
        end
        // break: hold the line low for a whole frame -> stop bit is low -> framing error
        rx_cnt = 0; line = 0; #(nominal * 10.5); line = 1; #(nominal * 2.0); repeat (4) @(negedge clk);
        $display("BREAK framing_error=%0d", fe_b);
        $finish;
    end
endmodule
