// The SystemVerilog traffic light must behave exactly like the Episode 8 Verilog version, cycle by cycle (steady and random ticks).
`timescale 1ns / 1ps
module tb_traffic_sv;
    logic clk = 0, rst = 1, tick = 1;
    logic [5:0] l_v, l_sv;
    int errors = 0, cycles = 0;
    fsm_traffic    #(.G(5), .Y(2)) ref_v (.clk(clk), .rst(rst), .tick(tick), .lights(l_v));
    fsm_traffic_sv #(.G(5), .Y(2)) dut   (.clk(clk), .rst(rst), .tick(tick), .lights(l_sv));
    always #5 clk = ~clk;
    // enum values can be printed by NAME: handy in the simulator log
    string last = "";
    always @(negedge clk) begin
        if (!rst) begin
            cycles++;
            if (l_v !== l_sv) errors++;
            if (dut.state.name() != last) begin
                last = dut.state.name();
                if (cycles < 80) $display("STATE %s at %0d ns", last, $time);
            end
        end
        if (cycles == 200) tick <= 1'b0;                  // second phase: random ticks
        if (cycles > 200)  tick <= ($urandom_range(0, 99) < 50);
    end
    initial begin
        $dumpfile("wave.vcd"); $dumpvars(0, tb_traffic_sv);
        #22 rst = 0;
        wait (cycles == 1200);
        $display("TRAFFIC cycles=%0d errors=%0d", cycles, errors);
        if (errors == 0) $display("PASS: the SystemVerilog traffic light matches the Verilog one on every cycle");
        else $display("FAILED: %0d mismatches", errors);
        $finish;
    end
endmodule
