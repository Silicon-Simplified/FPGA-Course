// Traffic light: check the exact green/yellow durations over two full cycles and that both directions are never green together.
`timescale 1ns / 1ps
module tb_traffic;
    localparam G = 5, Y = 2;
    reg clk = 0, rst = 1;
    reg tick = 1;
    wire [5:0] lights;
    integer errors = 0, run = 0, idx = 0;
    reg [5:0] prev = 6'bx;
    fsm_traffic #(.G(G), .Y(Y)) dut (.clk(clk), .rst(rst), .tick(tick), .lights(lights));
    wire [1:0] st = dut.state;
    always #5 clk = ~clk;
    initial begin
        $dumpfile("wave.vcd"); $dumpvars(0, tb_traffic);
        #22 rst = 0;
        #(10 * (2 * (G + Y)) * 2 + 7);
        if (idx < 7) begin errors = errors + 1; $display("FAIL: only %0d phases seen", idx); end
        if (errors == 0) $display("PASS: traffic light phases last exactly %0d/%0d ticks and greens never overlap", G, Y);
        else $display("FAILED: %0d errors", errors);
        $finish;
    end
    // measure phase lengths (the first phase is partial: reset is released mid-cycle, so it is not checked)
    always @(posedge clk) begin
        #1;
        if (!rst) begin
            if (lights[3] & lights[0]) begin errors = errors + 1; $display("FAIL: both green"); end
            if (lights === prev) run = run + 1;
            else begin
                if (prev !== 6'bx && idx >= 2 && run !== ((idx % 2) ? G : Y)) begin errors = errors + 1; $display("FAIL: phase %0d lasted %0d", idx, run); end
                if (prev !== 6'bx) idx = idx + 1; else idx = 1;
                run = 1; prev = lights;
            end
        end
    end
endmodule
