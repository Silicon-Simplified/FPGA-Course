// Episode 20 - one MMCM turns the PYNQ-Z2's 125 MHz clock into 250 MHz and 62.5 MHz.
// A counter runs in each clock domain; the LEDs show a few bits of each.
module clk_demo (input wire clk, output wire [3:0] led);
    wire fb, fb_b, c0, c1, c0_b, c1_b, locked;
    MMCME2_BASE #(
        .CLKIN1_PERIOD(8.000),          // 125 MHz in
        .DIVCLK_DIVIDE(1),
        .CLKFBOUT_MULT_F(8.000),        // VCO = 125 x 8 = 1000 MHz
        .CLKOUT0_DIVIDE_F(4.000),       // 1000 / 4  = 250 MHz
        .CLKOUT1_DIVIDE(16)             // 1000 / 16 = 62.5 MHz
    ) mmcm (.CLKIN1(clk), .CLKFBIN(fb_b), .CLKFBOUT(fb), .CLKOUT0(c0), .CLKOUT1(c1), .LOCKED(locked), .PWRDWN(1'b0), .RST(1'b0),
            .CLKFBOUTB(), .CLKOUT0B(), .CLKOUT1B(), .CLKOUT2(), .CLKOUT2B(), .CLKOUT3(), .CLKOUT3B(), .CLKOUT4(), .CLKOUT5(), .CLKOUT6());
    BUFG bfb (.I(fb), .O(fb_b));
    BUFG b0 (.I(c0), .O(c0_b));
    BUFG b1 (.I(c1), .O(c1_b));
    reg [27:0] n250 = 0;
    reg [23:0] n62 = 0;
    always @(posedge c0_b) n250 <= n250 + 28'd1;
    always @(posedge c1_b) n62  <= n62 + 24'd1;
    assign led = {locked, n62[23], n250[27], n250[26]};
endmodule
