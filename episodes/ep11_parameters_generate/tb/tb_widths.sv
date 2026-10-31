// ONE testbench checks the SAME counter at eleven widths (2..12 bits) using generate: each instance must wrap exactly at 2**W.
`timescale 1ns / 1ps
module tb_widths;
    localparam int WMIN = 2, WMAX = 12, CYCLES = 9000;
    logic clk = 0, rst = 1, en = 1;
    int ticks = 0;                       // enabled clock edges since reset
    logic [WMAX-1:0] bad = '0;           // one error flag per width
    int wraps_seen [WMIN:WMAX];
    always #5 clk = ~clk;
    genvar w;
    generate
        for (w = WMIN; w <= WMAX; w++) begin : g_w
            logic [w-1:0] q;
            cnt_n #(.W(w)) dut (.clk(clk), .rst(rst), .en(en), .q(q));
            logic [w-1:0] prev = '0;
            initial wraps_seen[w] = 0;
            always @(negedge clk) begin
                if (!rst) begin
                    if (q !== w'(ticks)) bad[w-1] <= 1'b1;               // reference: tick count truncated to w bits
                    if (q < prev) wraps_seen[w] <= wraps_seen[w] + 1;    // a wrap = the value went down
                    prev <= q;
                end
            end
        end
    endgenerate
    always @(posedge clk) if (!rst && en) ticks <= ticks + 1;
    initial begin
        #23 rst = 0;
        repeat (CYCLES) @(negedge clk);
        #1;
        for (int k = WMIN; k <= WMAX; k++) begin
            int expected_wraps = (CYCLES - 2) >> k;
            $display("WIDTH %0d bits: wraps=%0d error=%0d", k, wraps_seen[k], bad[k-1]);
        end
        $display("WIDTHS %0d..%0d bits, %0d cycles, flags=%b", WMIN, WMAX, CYCLES, bad);
        if (bad === '0) $display("PASS: every width of the same counter wraps exactly at 2**W");
        else $display("FAILED");
        $finish;
    end
endmodule
