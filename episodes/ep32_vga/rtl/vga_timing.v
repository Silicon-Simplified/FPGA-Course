// Episode 32 - VGA 640x480 timing generator. One pixel per clock: 800 clocks per line, 525 lines per frame.
//   horizontal: 640 visible + 16 front porch + 96 sync + 48 back porch = 800
//   vertical:   480 visible + 10 front porch +  2 sync + 33 back porch = 525
// Sync pulses are active LOW (the 640x480 standard).
module vga_timing (
    input  wire        clk,            // pixel clock
    input  wire        rst,
    output reg  [9:0]  h,              // 0..799
    output reg  [9:0]  v,              // 0..524
    output wire        active,         // inside the 640x480 picture
    output wire        hs_n,
    output wire        vs_n,
    output wire        frame_tick      // one pulse per frame, at the start of vertical blanking
);
    always @(posedge clk)
        if (rst) begin h <= 0; v <= 0; end
        else if (h == 10'd799) begin h <= 0; v <= (v == 10'd524) ? 10'd0 : v + 10'd1; end
        else h <= h + 10'd1;

    assign active     = (h < 10'd640) && (v < 10'd480);
    assign hs_n       = ~((h >= 10'd656) && (h < 10'd752));
    assign vs_n       = ~((v >= 10'd490) && (v < 10'd492));
    assign frame_tick = (h == 10'd0) && (v == 10'd480);
endmodule
