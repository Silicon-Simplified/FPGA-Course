// Episode 32 - a 64x48 box that bounces around the 640x480 screen, changing colour on every wall hit.
// It moves once per frame (during vertical blanking), so the picture never tears.
module bounce_logo (
    input  wire        clk,
    input  wire        rst,
    input  wire        frame_tick,
    output reg  [9:0]  x,              // top-left corner
    output reg  [9:0]  y,
    output reg  [2:0]  color_sel,
    output reg         bounce          // pulses for one clock when a wall was hit
);
    localparam W = 64, H = 48, SX = 3, SY = 2;
    reg dx = 1, dy = 1;                // 1 = moving right / down
    wire [10:0] nx = dx ? x + SX : x - SX;
    wire [10:0] ny = dy ? y + SY : y - SY;
    wire hit_x = dx ? (nx + W >= 640) : (nx[10] || nx == 0);
    wire hit_y = dy ? (ny + H >= 480) : (ny[10] || ny == 0);
    initial begin x = 100; y = 60; color_sel = 0; bounce = 0; end
    always @(posedge clk) begin
        bounce <= 0;
        if (rst) begin x <= 100; y <= 60; dx <= 1; dy <= 1; color_sel <= 0; end
        else if (frame_tick) begin
            x <= hit_x ? (dx ? 10'd640 - W : 10'd0) : nx[9:0];
            y <= hit_y ? (dy ? 10'd480 - H : 10'd0) : ny[9:0];
            if (hit_x) dx <= ~dx;
            if (hit_y) dy <= ~dy;
            if (hit_x || hit_y) begin color_sel <= color_sel + 3'd1; bounce <= 1; end
        end
    end
endmodule
