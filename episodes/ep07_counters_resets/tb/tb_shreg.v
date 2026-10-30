// The no-reset delay line must behave exactly like the sync-reset and async-reset ones once the pipeline is full.
`timescale 1ns / 1ps
module tb_shreg;
    reg clk = 0, rst = 1;
    reg [7:0] d = 0;
    wire [7:0] qa, qb, qc;
    integer errors = 0, n = 0;
    shreg_rst   a (.clk(clk), .rst(rst), .d(d), .q(qa));
    shreg_norst b (.clk(clk), .rst(rst), .d(d), .q(qb));
    shreg_arst  c (.clk(clk), .rst(rst), .d(d), .q(qc));
    always #5 clk = ~clk;
    reg [7:0] hist [0:255];
    always @(posedge clk) begin
        if (!rst) begin d <= d + 8'd3; hist[n[7:0]] <= d; n <= n + 1; end
        #1;
        if (!rst && n > 40) begin
            if (qa !== qb || qa !== qc) begin errors = errors + 1; $display("FAIL: outputs differ at n=%0d", n); end
            if (qb !== hist[(n - 32) & 255]) begin errors = errors + 1; $display("FAIL: not a 32-clock delay at n=%0d", n); end
        end
    end
    initial begin
        #23 rst = 0;
        #600;
        if (errors == 0) $display("PASS: delay line without reset behaves identically once full");
        else $display("FAILED: %0d errors", errors);
        $finish;
    end
endmodule
