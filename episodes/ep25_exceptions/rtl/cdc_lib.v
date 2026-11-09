// Episode 24 - a small clock-domain-crossing library.

// 1-bit level synchronizer: two flip-flops in the destination clock domain (ASYNC_REG keeps them together and tells Vivado they are a synchronizer).
module sync2 (input wire clk, input wire d, output wire q);
    (* ASYNC_REG = "TRUE" *) reg s1 = 0, s2 = 0;
    always @(posedge clk) begin s1 <= d; s2 <= s1; end
    assign q = s2;
endmodule

// pulse synchronizer: a one-cycle pulse in clock A becomes a one-cycle pulse in clock B (toggle, synchronize, detect the edge)
module pulse_sync (input wire clk_a, input wire pulse_a, input wire clk_b, output wire pulse_b);
    reg tog = 0;
    always @(posedge clk_a) if (pulse_a) tog <= ~tog;
    wire tog_b;
    sync2 s (.clk(clk_b), .d(tog), .q(tog_b));
    reg prev = 0;
    always @(posedge clk_b) prev <= tog_b;
    assign pulse_b = tog_b ^ prev;
endmodule

// binary <-> Gray code
module bin2gray #(parameter W = 8) (input wire [W-1:0] b, output wire [W-1:0] g);
    assign g = b ^ (b >> 1);
endmodule
module gray2bin #(parameter W = 8) (input wire [W-1:0] g, output reg [W-1:0] b);
    integer i;
    always @* begin b[W-1] = g[W-1]; for (i = W-2; i >= 0; i = i - 1) b[i] = b[i+1] ^ g[i]; end
endmodule

// asynchronous FIFO (depth 2**AW): binary pointers inside each domain, Gray-coded pointers synchronized across
module async_fifo #(parameter DW = 8, AW = 4) (
    input  wire wclk, input wire winc, input wire [DW-1:0] wdata, output wire wfull,
    input  wire rclk, input wire rinc, output wire [DW-1:0] rdata, output wire rempty);
    reg [DW-1:0] mem [0:(1<<AW)-1];
    reg [AW:0] wbin = 0, rbin = 0;
    wire [AW:0] wgray, rgray, wgray_r, rgray_w;
    bin2gray #(AW+1) g1 (.b(wbin), .g(wgray));
    bin2gray #(AW+1) g2 (.b(rbin), .g(rgray));
    reg [AW:0] wgray_q = 0, rgray_q = 0;
    always @(posedge wclk) wgray_q <= wgray;          // registered Gray pointers leave their domain
    always @(posedge rclk) rgray_q <= rgray;
    genvar i;
    generate for (i = 0; i <= AW; i = i + 1) begin : sy
        sync2 a (.clk(rclk), .d(wgray_q[i]), .q(wgray_r[i]));
        sync2 b (.clk(wclk), .d(rgray_q[i]), .q(rgray_w[i]));
    end endgenerate
    assign wfull  = (wgray == {~rgray_w[AW:AW-1], rgray_w[AW-2:0]});
    assign rempty = (rgray == wgray_r);
    always @(posedge wclk) if (winc && !wfull) begin mem[wbin[AW-1:0]] <= wdata; wbin <= wbin + 1'b1; end
    always @(posedge rclk) if (rinc && !rempty) rbin <= rbin + 1'b1;
    assign rdata = mem[rbin[AW-1:0]];
endmodule
