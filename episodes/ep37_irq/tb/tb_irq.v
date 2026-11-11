// Episode 37 - an AXI4-Lite master model and a "button with bounce" drive axil_irq: debouncing, the level interrupt, masking, write-1-to-clear, and 20 noisy presses.
// MUT = 0 correct design; MUT = 1 no debounce; MUT = 2 an acknowledge clears every pending bit instead of only the written ones.
`timescale 1ns/1ps
module tb_irq #(parameter MUT = 0);
    localparam DEB = 16;                                          // short debounce for simulation (the real design uses 1,000,000 clocks = 10 ms at 100 MHz)
    reg clk = 0; always #5 clk = ~clk;
    reg rstn = 0;
    reg [4:0] awaddr = 0, araddr = 0; reg awvalid = 0, wvalid = 0, bready = 0, arvalid = 0, rready = 0; reg [31:0] wdata = 0; reg [3:0] btn = 0;
    wire awready, wready, bvalid, arready, rvalid, irq; wire [1:0] bresp, rresp; wire [31:0] rdata;
    axil_irq #(DEB, (MUT == 1) ? 1 : 0, (MUT == 2) ? 1 : 0) dut (.s_axi_aclk(clk), .s_axi_aresetn(rstn), .s_axi_awaddr(awaddr), .s_axi_awvalid(awvalid), .s_axi_awready(awready),
        .s_axi_wdata(wdata), .s_axi_wstrb(4'hF), .s_axi_wvalid(wvalid), .s_axi_wready(wready), .s_axi_bresp(bresp), .s_axi_bvalid(bvalid), .s_axi_bready(bready),
        .s_axi_araddr(araddr), .s_axi_arvalid(arvalid), .s_axi_arready(arready), .s_axi_rdata(rdata), .s_axi_rresp(rresp), .s_axi_rvalid(rvalid), .s_axi_rready(rready), .btn(btn), .irq(irq));
    integer checks = 0, errs = 0;
    task check(input [31:0] got, input [31:0] exp); begin checks = checks + 1; if (got !== exp) errs = errs + 1; end endtask
    task wr(input [4:0] a, input [31:0] d);
        begin @(negedge clk); bready = 1; awaddr = a; awvalid = 1; wdata = d; wvalid = 1;
            @(posedge clk); while (!(awready && wready)) @(posedge clk); @(negedge clk); awvalid = 0; wvalid = 0;
            while (!bvalid) @(posedge clk); @(negedge clk); bready = 0; end
    endtask
    reg [31:0] rv;
    task rd(input [4:0] a);
        begin @(negedge clk); araddr = a; arvalid = 1; rready = 1; @(posedge clk); while (!arready) @(posedge clk); @(negedge clk); arvalid = 0;
            while (!rvalid) @(posedge clk); rv = rdata; @(negedge clk); rready = 0; end
    endtask
    // a press with nb bounces (each glitch: 3 clocks high, 3 clocks low), then held; the release bounces too
    task press(input integer b, input integer nb, input integer hold);
        integer j;
        begin
            for (j = 0; j < nb; j = j + 1) begin @(negedge clk); btn[b] = 1; repeat (3) @(negedge clk); btn[b] = 0; repeat (3) @(negedge clk); end
            btn[b] = 1; repeat (hold) @(negedge clk);
            for (j = 0; j < nb; j = j + 1) begin btn[b] = 0; repeat (3) @(negedge clk); btn[b] = 1; repeat (3) @(negedge clk); end
            btn[b] = 0; repeat (4 * DEB) @(negedge clk);
        end
    endtask
    integer i, c0, t0, lat; reg [31:0] seed;
    initial begin
        seed = 32'h1F2E3D4C;
        repeat (5) @(negedge clk); rstn = 1; repeat (2) @(negedge clk);
        rd(5'h10); check(rv, 32'h49525101); rd(5'h04); check(rv, 0); rd(5'h08); check(rv, 0); rd(5'h0C); check(rv, 0); check(irq, 0);
        // 1: one press of button 0 with 3 bounces, interrupt enabled
        wr(5'h08, 1);
        t0 = $time; btn[0] = 1; @(negedge clk); btn[0] = 0; repeat (3) @(negedge clk);
        press(0, 3, 6 * DEB);
        rd(5'h04); check(rv, 1); rd(5'h0C); check(rv, 1); check(irq, 1);
        repeat (50) @(negedge clk); check(irq, 1);                                 // a level: still high until acknowledged
        wr(5'h04, 1); rd(5'h04); check(rv, 0); check(irq, 0);
        // 2: masked: pending is set, irq is not; unmasking raises it at once
        wr(5'h08, 0); press(1, 2, 6 * DEB);
        rd(5'h04); check(rv, 2); check(irq, 0);
        wr(5'h08, 2); @(negedge clk); check(irq, 1);
        wr(5'h04, 2); check(irq, 0);
        // 3: two buttons pending; acknowledging one must leave the other
        wr(5'h08, 4'hF);
        fork press(2, 1, 6 * DEB); begin repeat (5) @(negedge clk); press(3, 1, 6 * DEB); end join
        rd(5'h04); check(rv, 4'hC); check(irq, 1);
        wr(5'h04, 4); rd(5'h04); check(rv, 4'h8); check(irq, 1);
        wr(5'h04, 8); rd(5'h04); check(rv, 0); check(irq, 0);
        // 4: 20 noisy presses of button 0 (1..6 bounces each), acknowledged one by one
        rd(5'h0C); c0 = rv;
        for (i = 0; i < 20; i = i + 1) begin seed = seed * 1664525 + 1013904223; press(0, 1 + (seed >> 16) % 6, 6 * DEB); wr(5'h04, 1); end
        rd(5'h0C); check(rv - c0, 20);
        // latency: first contact of a clean press -> irq high
        wr(5'h08, 1); t0 = 0; @(negedge clk); btn[0] = 1; while (!irq) begin @(negedge clk); t0 = t0 + 1; end lat = t0; wr(5'h04, 1); btn[0] = 0; repeat (6 * DEB) @(negedge clk);
        $display("IRQ mut %0d: %0d checks, %0d errors; events counted for 20 noisy presses: %0d; clean press to interrupt: %0d clocks (debounce %0d)", MUT, checks, errs, rv - c0, lat, DEB);
        $finish;
    end
endmodule
