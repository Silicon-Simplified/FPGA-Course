// A bouncy button pressed twice: the naive edge counter sees many "presses", the debouncer exactly two.
`timescale 1ns / 1ps
module tb_debounce;
    localparam N = 8;                               // stable for 8 clocks = 80 ns
    reg clk = 0, rst = 1, btn = 0;
    wire press, level;
    integer errors = 0, naive = 0, presses = 0;
    debounce #(.N(N)) dut (.clk(clk), .rst(rst), .btn(btn), .press(press), .level(level));
    wire sync_btn = dut.s2;
    always #5 clk = ~clk;
    reg s2_prev = 0;
    always @(posedge clk) begin
        s2_prev <= sync_btn;
        if (sync_btn && !s2_prev) naive = naive + 1;   // what a counter without debouncing would count
        if (press) presses = presses + 1;
    end
    task bounce_press; begin
        btn = 1; #20 btn = 0; #13 btn = 1; #17 btn = 0; #11 btn = 1; #23 btn = 0; #9 btn = 1;
    end endtask
    task bounce_release; begin
        btn = 0; #17 btn = 1; #14 btn = 0; #19 btn = 1; #12 btn = 0;
    end endtask
    initial begin
        $dumpfile("wave.vcd"); $dumpvars(0, tb_debounce);
        #22 rst = 0;
        #30 bounce_press;  #300 bounce_release;  #300;
        #25 bounce_press;  #300 bounce_release;  #300;
        $display("DEBOUNCE naive_edges=%0d debounced_presses=%0d", naive, presses);
        if (presses !== 2) begin errors = errors + 1; $display("FAIL: expected 2 debounced presses"); end
        if (naive < 6)     begin errors = errors + 1; $display("FAIL: expected many raw edges"); end
        if (errors == 0) $display("PASS: debouncer turns every bouncy press into exactly one pulse");
        else $display("FAILED: %0d errors", errors);
        $finish;
    end
endmodule
