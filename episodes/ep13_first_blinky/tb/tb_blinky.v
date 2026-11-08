// Self-checking test with a tiny clock (CLK_HZ = 64): each speed must step the LED counter every 64 >> sw cycles; BTN0 must reset.
`timescale 1ns / 1ps
module tb_blinky;
    reg clk = 0, btn = 0;
    reg [1:0] sw = 0;
    wire [3:0] led;
    integer errors = 0, cyc = 0, last = 0, k;
    blinky #(.CLK_HZ(64)) dut (.clk(clk), .btn(btn), .sw(sw), .led(led));
    always #5 clk = ~clk;
    always @(posedge clk) cyc <= cyc + 1;
    reg [3:0] prev = 0;
    integer spacing [0:3];
    integer seen;
    initial begin
        $dumpfile("wave.vcd"); $dumpvars(0, tb_blinky);
        for (k = 0; k < 4; k = k + 1) begin
            sw = k[1:0]; btn = 1; repeat (6) @(negedge clk); btn = 0;           // reset, then run
            prev = led; seen = 0; spacing[k] = 0;
            repeat (400) begin
                @(negedge clk);
                if (led !== prev) begin
                    seen = seen + 1;
                    if (seen == 2) spacing[k] = cyc - last;                      // distance between two consecutive steps
                    last = cyc; prev = led;
                end
            end
            $display("SPEED sw=%0d  cycles between LED steps = %0d  (expected %0d)", sw, spacing[k], 64 >> k);
            if (spacing[k] !== (64 >> k)) errors = errors + 1;
        end
        // BTN0 resets the LED counter
        sw = 0; repeat (200) @(negedge clk);
        btn = 1; repeat (6) @(negedge clk);
        if (led !== 4'd0) begin errors = errors + 1; $display("FAIL: reset did not clear the LEDs"); end
        btn = 0;
        if (errors == 0) $display("PASS: LED counter steps every CLK_HZ>>sw cycles and BTN0 resets it");
        else $display("FAILED: %0d errors", errors);
        $finish;
    end
endmodule
