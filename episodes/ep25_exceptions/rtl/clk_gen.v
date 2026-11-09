// 125 MHz in -> 250 MHz (clk_a) and 62.5 MHz (clk_b) from one MMCM (see Episode 20)
module clk_gen (input wire clk, output wire clk_a, output wire clk_b);
    wire fb, fb_b, c0, c1, locked;
    MMCME2_BASE #(.CLKIN1_PERIOD(8.000), .DIVCLK_DIVIDE(1), .CLKFBOUT_MULT_F(8.000), .CLKOUT0_DIVIDE_F(4.000), .CLKOUT1_DIVIDE(16))
        mmcm (.CLKIN1(clk), .CLKFBIN(fb_b), .CLKFBOUT(fb), .CLKOUT0(c0), .CLKOUT1(c1), .LOCKED(locked), .PWRDWN(1'b0), .RST(1'b0),
              .CLKFBOUTB(), .CLKOUT0B(), .CLKOUT1B(), .CLKOUT2(), .CLKOUT2B(), .CLKOUT3(), .CLKOUT3B(), .CLKOUT4(), .CLKOUT5(), .CLKOUT6());
    BUFG b_fb (.I(fb), .O(fb_b));
    BUFG b0 (.I(c0), .O(clk_a));
    BUFG b1 (.I(c1), .O(clk_b));
endmodule
