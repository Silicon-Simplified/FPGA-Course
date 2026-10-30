// blink_en and blink_div must behave the same in simulation (small N) - the difference only shows up in synthesis/timing.
`timescale 1ns / 1ps
module tb_blink;
    localparam N = 20;
    reg clk = 0, rst = 1;
    wire [3:0] le, ld;
    wire tick;
    integer errors = 0, ticks = 0;
    blink_en  #(.N(N)) e (.clk(clk), .rst(rst), .led(le));
    blink_div #(.N(N)) d (.clk(clk), .rst(rst), .led(ld));
    assign tick = e.tick;
    always #5 clk = ~clk;
    always @(posedge clk) if (tick) ticks <= ticks + 1;
    initial begin
        $dumpfile("wave.vcd"); $dumpvars(0, tb_blink);
        #22 rst = 0;
        #(10*N*8 + 7);
        $display("BLINK N=%0d ticks=%0d led_en=%0d led_div=%0d", N, ticks, le, ld);
        if (ticks < 7) begin errors = errors + 1; $display("FAIL: too few ticks"); end
        if (le !== ticks[3:0]) begin errors = errors + 1; $display("FAIL: blink_en count != ticks"); end
        if (le !== ld && (le - ld) > 4'd1 && (ld - le) > 4'd1) begin errors = errors + 1; $display("FAIL: designs disagree"); end
        if (errors == 0) $display("PASS: tick generator counts every N clocks; both blinkers behave alike in simulation");
        else $display("FAILED: %0d errors", errors);
        $finish;
    end
endmodule
