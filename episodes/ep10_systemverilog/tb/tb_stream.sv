// Random-stall test of the interface-based register slice. A SystemVerilog QUEUE is the scoreboard.
`timescale 1ns / 1ps
module tb_stream;
    logic clk = 0, rst = 1;
    if_stream i (), o ();
    stream_slice dut (.clk(clk), .rst(rst), .in(i), .out(o));
    always #5 clk = ~clk;
    logic [7:0] exp_q[$];
    int errors = 0, n_in = 0, n_out = 0, stalls = 0, seq = 0;
    bit took = 1, drain = 0;
    // monitor: sample just before every rising edge (all drives happen on the falling edge)
    always @(posedge clk) begin
        if (!rst) begin
            took = 0;
            if (i.valid && i.ready) begin exp_q.push_back(i.data); n_in++; took = 1; end
            if (o.valid && o.ready) begin
                n_out++;
                if (exp_q.size() == 0) errors++;
                else if (o.data !== exp_q.pop_front()) errors++;
            end
            if (o.valid && !o.ready) stalls++;
        end
    end
    // driver: new word after a transfer (or when idle); random valid, random ready
    always @(negedge clk) begin
        if (!rst) begin
            o.ready <= drain ? 1'b1 : ($urandom_range(0, 99) < 55);
            if (took || !i.valid) begin
                i.valid <= drain ? 1'b0 : ($urandom_range(0, 99) < 70);
                i.data  <= 8'(seq);
                seq <= seq + 1;
            end
        end
    end
    initial begin
        i.valid = 0; i.data = 0; o.ready = 0;
        $dumpfile("wave.vcd"); $dumpvars(0, tb_stream);
        #23 rst = 0;
        #40000 drain = 1;
        #200;
        $display("STREAM transfers_in=%0d transfers_out=%0d errors=%0d backpressure_cycles=%0d", n_in, n_out, errors, stalls);
        if (errors == 0 && n_in == n_out && n_in > 1000) $display("PASS: no word lost, duplicated or reordered under random stalls");
        else $display("FAILED");
        $finish;
    end
endmodule
