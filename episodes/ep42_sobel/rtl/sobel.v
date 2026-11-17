// Episode 42 - a streaming Sobel edge detector for 8-bit grayscale video. One pixel per accepted clock (in_valid); the pipeline only moves when a pixel is accepted.
//   two line buffers (W pixels each) give the pixel of the row above and two rows above; a 3x3 window of registers slides along the row; |gx| + |gy| is clamped to 255.
//   The window's centre pixel lags the newest input by W + 1 pixels. Border pixels (first/last row and column) are forced to 0, so the output frame has the same size and the same order as the input frame.
// BUG = 1: line buffers one pixel too short (the rows drift);  BUG = 2: no clamping (the 8-bit result wraps around). Both are used only by the testbench.
module sobel #(parameter W = 128, parameter H = 96, parameter BUG = 0) (
    input  wire       clk,
    input  wire       rst,
    input  wire       in_valid,
    input  wire [7:0] in_pix,
    output reg        out_valid,
    output wire [7:0] out_pix
);
    localparam DEPTH = (BUG == 1) ? W - 1 : W;
    localparam PW = $clog2(W + 1);
    reg [7:0] m1 [0:DEPTH-1];
    reg [7:0] m2 [0:DEPTH-1];
    reg [PW-1:0] ptr;
    wire [7:0] rd1 = m1[ptr];                      // the pixel that was written DEPTH steps ago (read before the write)
    wire [7:0] rd2 = m2[ptr];                      // and the one from the row before it
    reg [7:0] w0 [0:2], w1 [0:2], w2 [0:2];        // window rows: w0 = newest row, w2 = oldest; index 0 = newest column
    reg [PW:0] fill;
    reg [PW-1:0] cx; reg [$clog2(H+1)-1:0] cy; reg started;
    integer k;
    always @(posedge clk)
        if (rst) begin
            ptr <= 0; fill <= W + 1; cx <= 0; cy <= 0; started <= 0; out_valid <= 0;
            for (k = 0; k < 3; k = k + 1) begin w0[k] <= 0; w1[k] <= 0; w2[k] <= 0; end
        end else begin
            out_valid <= 0;
            if (in_valid) begin
                m1[ptr] <= in_pix; m2[ptr] <= rd1;
                ptr <= (ptr == DEPTH - 1) ? 0 : ptr + 1;
                w0[0] <= in_pix; w0[1] <= w0[0]; w0[2] <= w0[1];
                w1[0] <= rd1;    w1[1] <= w1[0]; w1[2] <= w1[1];
                w2[0] <= rd2;    w2[1] <= w2[0]; w2[2] <= w2[1];
                if (fill != 0) fill <= fill - 1;
                else begin
                    out_valid <= 1;
                    if (started) begin
                        if (cx == W - 1) begin cx <= 0; cy <= (cy == H - 1) ? 0 : cy + 1; end else cx <= cx + 1;
                    end else started <= 1;
                end
            end
        end
    // window as a 3x3 picture:  a b c / d e f / g h i   (top row = oldest row, left column = oldest column)
    wire signed [11:0] a = w2[2], b = w2[1], c = w2[0], d = w1[2], f = w1[0], g = w0[2], h = w0[1], i = w0[0];
    wire signed [11:0] gx = (c + 2 * f + i) - (a + 2 * d + g);
    wire signed [11:0] gy = (g + 2 * h + i) - (a + 2 * b + c);
    wire [11:0] mag = (gx < 0 ? -gx : gx) + (gy < 0 ? -gy : gy);
    wire [7:0] mag8 = (BUG == 2) ? mag[7:0] : ((mag > 12'd255) ? 8'd255 : mag[7:0]);
    wire interior = (cx != 0) && (cx != W - 1) && (cy != 0) && (cy != H - 1);
    assign out_pix = interior ? mag8 : 8'd0;
endmodule
