// Episode 35 - an AXI4-Lite master model drives axil_pwm: reset values, read-back in all three write orderings, byte strobes, read-only registers, and the PWM duty measured on the output pins.
// MUT = 0 correct design; MUT = 1 ignores byte strobes; MUT = 2 uses the live address instead of the captured one.
`timescale 1ns/1ps
module tb_axil #(parameter MUT = 0);
    reg clk = 0; always #5 clk = ~clk;                         // 100 MHz (the PS clock in the block design)
    reg rstn = 0;
    reg [4:0] awaddr = 0, araddr = 0; reg awvalid = 0, wvalid = 0, bready = 0, arvalid = 0, rready = 0; reg [31:0] wdata = 0; reg [3:0] wstrb = 4'hF;
    wire awready, wready, bvalid, arready, rvalid; wire [1:0] bresp, rresp; wire [31:0] rdata; wire [3:0] pwm;
    axil_pwm #((MUT == 1) ? 0 : 1, (MUT == 2) ? 0 : 1) dut (.s_axi_aclk(clk), .s_axi_aresetn(rstn), .s_axi_awaddr(awaddr), .s_axi_awvalid(awvalid), .s_axi_awready(awready),
        .s_axi_wdata(wdata), .s_axi_wstrb(wstrb), .s_axi_wvalid(wvalid), .s_axi_wready(wready), .s_axi_bresp(bresp), .s_axi_bvalid(bvalid), .s_axi_bready(bready),
        .s_axi_araddr(araddr), .s_axi_arvalid(arvalid), .s_axi_arready(arready), .s_axi_rdata(rdata), .s_axi_rresp(rresp), .s_axi_rvalid(rvalid), .s_axi_rready(rready), .pwm(pwm));

    integer checks = 0, errs = 0, wr_clks = 0, rd_clks = 0, t0;
    task check(input [31:0] got, input [31:0] exp);
        begin checks = checks + 1; if (got !== exp) errs = errs + 1; end
    endtask
    // mode 0: AW and W together; 1: AW first, then (after 3 clocks) W; 2: W first, then AW. After AW is taken the address bus is driven to the ID register (0x1C): a real master moves on.
    task wr(input [4:0] a, input [31:0] d, input [3:0] s, input integer mode);
        begin
            t0 = $time;
            @(negedge clk);
            bready = 1;
            if (mode == 0) begin awaddr = a; awvalid = 1; wdata = d; wstrb = s; wvalid = 1;
                @(posedge clk); while (!(awready && wready)) @(posedge clk); @(negedge clk); awvalid = 0; wvalid = 0; awaddr = 5'h1C; end
            else if (mode == 1) begin awaddr = a; awvalid = 1;
                @(posedge clk); while (!awready) @(posedge clk); @(negedge clk); awvalid = 0; awaddr = 5'h1C;
                repeat (3) @(negedge clk); wdata = d; wstrb = s; wvalid = 1; @(posedge clk); while (!wready) @(posedge clk); @(negedge clk); wvalid = 0; end
            else begin wdata = d; wstrb = s; wvalid = 1;
                @(posedge clk); while (!wready) @(posedge clk); @(negedge clk); wvalid = 0;
                repeat (3) @(negedge clk); awaddr = a; awvalid = 1; @(posedge clk); while (!awready) @(posedge clk); @(negedge clk); awvalid = 0; awaddr = 5'h1C; end
            while (!bvalid) @(posedge clk);
            check(bresp, 0);
            @(negedge clk); bready = 0;
            if (mode == 0) wr_clks = ($time - t0) / 10;
        end
    endtask
    reg [31:0] rd_val;
    task rd(input [4:0] a);
        begin
            t0 = $time;
            @(negedge clk); araddr = a; arvalid = 1; rready = 1;
            @(posedge clk); while (!arready) @(posedge clk); @(negedge clk); arvalid = 0;
            while (!rvalid) @(posedge clk);
            rd_val = rdata; check(rresp, 0);
            @(negedge clk); rready = 0; rd_clks = ($time - t0) / 10;
        end
    endtask
    integer i, m, k; reg [31:0] pat;
    integer hi0, hi1, hi2, hi3, n;
    initial begin
        repeat (5) @(negedge clk); rstn = 1; repeat (2) @(negedge clk);
        // reset values
        rd(5'h1C); check(rd_val, 32'h50574D01); rd(5'h00); check(rd_val, 0); rd(5'h04); check(rd_val, 1000);
        for (i = 2; i < 6; i = i + 1) begin rd(i * 4); check(rd_val, 0); end
        // write / read-back of the 6 writable registers, in all 3 orderings
        for (m = 0; m < 3; m = m + 1)
            for (i = 0; i < 6; i = i + 1) begin
                pat = 32'hA5A50000 + (m * 16 + i) * 32'h111 + 1;
                wr(i * 4, pat, 4'hF, m); rd(i * 4); check(rd_val, pat);
            end
        // byte strobes: only bytes 0 and 2 change
        wr(5'h08, 32'h11223344, 4'hF, 0); wr(5'h08, 32'hAABBCCDD, 4'b0101, 0); rd(5'h08); check(rd_val, 32'h11BB33DD);
        wr(5'h08, 32'hFFFFFFFF, 4'b1000, 1); rd(5'h08); check(rd_val, 32'hFFBB33DD);
        // read-only registers ignore writes (and still answer OKAY)
        wr(5'h1C, 32'hDEADBEEF, 4'hF, 0); rd(5'h1C); check(rd_val, 32'h50574D01);
        wr(5'h18, 32'hDEADBEEF, 4'hF, 2); rd(5'h18); check(rd_val[31:16], 0);
        // PWM: period 1000, duties 0 / 250 / 500 / 1000, measured over 10 periods
        wr(5'h00, 0, 4'hF, 0); wr(5'h04, 1000, 4'hF, 0); wr(5'h08, 0, 4'hF, 0); wr(5'h0C, 250, 4'hF, 0); wr(5'h10, 500, 4'hF, 0); wr(5'h14, 1000, 4'hF, 0);
        hi0 = 0; hi1 = 0; hi2 = 0; hi3 = 0;
        repeat (50) @(posedge clk); check(pwm, 4'b0000);                               // disabled: all low
        wr(5'h00, 1, 4'hF, 0);
        @(negedge clk); while (dut.cnt != 0) @(negedge clk);
        for (n = 0; n < 10000; n = n + 1) begin
            @(posedge clk); hi0 = hi0 + pwm[0]; hi1 = hi1 + pwm[1]; hi2 = hi2 + pwm[2]; hi3 = hi3 + pwm[3];
        end
        check(hi0, 0); check(hi1, 2500); check(hi2, 5000); check(hi3, 10000);
        $display("AXIL mut %0d: %0d checks, %0d errors; write %0d clocks, read %0d clocks; PWM high clocks in 10 periods: %0d %0d %0d %0d", MUT, checks, errs, wr_clks, rd_clks, hi0, hi1, hi2, hi3);
        $finish;
    end
endmodule
