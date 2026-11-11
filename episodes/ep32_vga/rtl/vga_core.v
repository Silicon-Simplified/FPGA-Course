// Episode 32 - the pixel pipeline: timing -> pixel colour -> output register.
// The colour is looked up from the counters in stage 0; stage 1 registers colour AND sync together,
// so the sync lines stay aligned with the pixels (the classic "off by one" bug is delaying only one of them).
module vga_core (
    input  wire        clk,            // 25 MHz pixel clock
    input  wire        rst,
    output reg  [3:0]  r, g, b,
    output reg         hs_n, vs_n,
    output wire        bounce
);
    wire [9:0] h, v, lx, ly;
    wire active, hs0, vs0, tick;
    wire [2:0] sel;
    vga_timing  tm (.clk(clk), .rst(rst), .h(h), .v(v), .active(active), .hs_n(hs0), .vs_n(vs0), .frame_tick(tick));
    bounce_logo lg (.clk(clk), .rst(rst), .frame_tick(tick), .x(lx), .y(ly), .color_sel(sel), .bounce(bounce));

    wire in_logo = (h >= lx) && (h < lx + 10'd64) && (v >= ly) && (v < ly + 10'd48);
    reg [11:0] logo;
    always @* case (sel)
        3'd0: logo = 12'hF22;  3'd1: logo = 12'hFA2;  3'd2: logo = 12'hFE2;  3'd3: logo = 12'h2D4;
        3'd4: logo = 12'h2DD;  3'd5: logo = 12'h34F;  3'd6: logo = 12'hA3F;  default: logo = 12'hF3A;
    endcase
    // background: a light-grey grid, 32 pixel cells
    wire gridline = (h[4:0] == 5'd0) || (v[4:0] == 5'd0);
    wire [11:0] bg  = gridline ? 12'hBBB : 12'hEEE;
    wire [11:0] pix = in_logo ? logo : bg;

    always @(posedge clk) begin
        {r, g, b} <= active ? pix : 12'h000;      // blanking must be black
        hs_n <= hs0;
        vs_n <= vs0;
    end
endmodule
