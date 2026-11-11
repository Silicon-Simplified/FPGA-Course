// Episode 32 - PYNQ-Z2 top level: one MMCM makes the 25 MHz pixel clock from the 125 MHz board clock.
// The board has no VGA connector, so the 12-bit colour + 2 sync signals go to the Pmod headers (resistor-ladder VGA Pmod style).
module vga_top (
    input  wire        clk,            // 125 MHz
    output wire [3:0]  vga_r, vga_g, vga_b,
    output wire        vga_hs, vga_vs,
    output wire [3:0]  led
);
    wire fb, fb_b, c0, pclk, locked, bounce;
    MMCME2_BASE #(.CLKIN1_PERIOD(8.000), .DIVCLK_DIVIDE(1), .CLKFBOUT_MULT_F(8.000), .CLKOUT0_DIVIDE_F(40.000))   // 1000 MHz / 40 = 25 MHz
        mmcm (.CLKIN1(clk), .CLKFBIN(fb_b), .CLKFBOUT(fb), .CLKOUT0(c0), .LOCKED(locked), .PWRDWN(1'b0), .RST(1'b0),
              .CLKFBOUTB(), .CLKOUT0B(), .CLKOUT1(), .CLKOUT1B(), .CLKOUT2(), .CLKOUT2B(), .CLKOUT3(), .CLKOUT3B(), .CLKOUT4(), .CLKOUT5(), .CLKOUT6());
    BUFG bfb (.I(fb), .O(fb_b));
    BUFG bpx (.I(c0), .O(pclk));

    reg [2:0] rs = 3'b111;                                  // hold the video core in reset until the clock is stable
    always @(posedge pclk) rs <= {rs[1:0], ~locked};
    wire [3:0] r, g, b; wire hs_n, vs_n;
    vga_core core (.clk(pclk), .rst(rs[2]), .r(r), .g(g), .b(b), .hs_n(hs_n), .vs_n(vs_n), .bounce(bounce));
    assign {vga_r, vga_g, vga_b, vga_hs, vga_vs} = {r, g, b, hs_n, vs_n};

    reg tog = 0; always @(posedge pclk) if (bounce) tog <= ~tog;
    assign led = {locked, tog, 2'b00};
endmodule
