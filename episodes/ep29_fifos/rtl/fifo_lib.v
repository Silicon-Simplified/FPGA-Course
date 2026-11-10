// Episode 29 - a synchronous FIFO written two ways, and wrappers around the XPM FIFO macros.

// Standard-mode synchronous FIFO: read data appears ONE clock after rd_en. Memory has a clocked read, so Vivado can use block RAM.
module sync_fifo_std #(parameter DW = 16, AW = 4) (
    input  wire clk, input wire rst, input wire wr_en, input wire [DW-1:0] din, input wire rd_en, output reg [DW-1:0] dout,
    output wire full, output wire empty, output wire [AW:0] count);
    reg [DW-1:0] mem [0:(1<<AW)-1];
    reg [AW:0] wp = 0, rp = 0;
    assign count = wp - rp;
    assign full  = (count == (1 << AW));
    assign empty = (count == 0);
    always @(posedge clk) begin
        if (rst) begin wp <= 0; rp <= 0; end
        else begin
            if (wr_en && !full)  begin mem[wp[AW-1:0]] <= din; wp <= wp + 1'b1; end
            if (rd_en && !empty) begin dout <= mem[rp[AW-1:0]]; rp <= rp + 1'b1; end
        end
    end
endmodule

// First-word-fall-through FIFO: the oldest word is ALREADY on dout while empty is low; rd_en just removes it (zero read latency, asynchronous read).
module sync_fifo_fwft #(parameter DW = 16, AW = 4) (
    input  wire clk, input wire rst, input wire wr_en, input wire [DW-1:0] din, input wire rd_en, output wire [DW-1:0] dout,
    output wire full, output wire empty, output wire [AW:0] count);
    reg [DW-1:0] mem [0:(1<<AW)-1];
    reg [AW:0] wp = 0, rp = 0;
    assign count = wp - rp;
    assign full  = (count == (1 << AW));
    assign empty = (count == 0);
    assign dout  = mem[rp[AW-1:0]];
    always @(posedge clk) begin
        if (rst) begin wp <= 0; rp <= 0; end
        else begin
            if (wr_en && !full)  begin mem[wp[AW-1:0]] <= din; wp <= wp + 1'b1; end
            if (rd_en && !empty) rp <= rp + 1'b1;
        end
    end
endmodule

// XPM synchronous FIFO (parameters: depth, memory type, read mode)
module xs #(parameter DEPTH = 512, parameter MEM = "auto", parameter MODE = "std") (
    input wire clk, input wire rst, input wire wr_en, input wire [15:0] din, input wire rd_en, output wire [15:0] dout, output wire full, output wire empty,
    output wire almost_full, output wire [$clog2(DEPTH):0] data_count);
    xpm_fifo_sync #(.FIFO_MEMORY_TYPE(MEM), .FIFO_WRITE_DEPTH(DEPTH), .WRITE_DATA_WIDTH(16), .READ_DATA_WIDTH(16), .READ_MODE(MODE), .FIFO_READ_LATENCY(MODE == "std" ? 1 : 0),
                    .USE_ADV_FEATURES("0707"), .PROG_FULL_THRESH(DEPTH - 8), .WR_DATA_COUNT_WIDTH($clog2(DEPTH) + 1), .RD_DATA_COUNT_WIDTH($clog2(DEPTH) + 1), .FULL_RESET_VALUE(0))
        f (.wr_clk(clk), .rst(rst), .wr_en(wr_en), .din(din), .rd_en(rd_en), .dout(dout), .full(full), .empty(empty), .prog_full(almost_full), .wr_data_count(data_count),
           .sleep(1'b0), .injectsbiterr(1'b0), .injectdbiterr(1'b0));
endmodule

// XPM asynchronous FIFO
module xa #(parameter DEPTH = 512) (
    input wire wclk, input wire rclk, input wire rst, input wire wr_en, input wire [15:0] din, input wire rd_en, output wire [15:0] dout, output wire full, output wire empty);
    xpm_fifo_async #(.FIFO_MEMORY_TYPE("auto"), .FIFO_WRITE_DEPTH(DEPTH), .WRITE_DATA_WIDTH(16), .READ_DATA_WIDTH(16), .READ_MODE("std"), .FIFO_READ_LATENCY(1), .CDC_SYNC_STAGES(2), .RELATED_CLOCKS(0), .USE_ADV_FEATURES("0000"))
        f (.wr_clk(wclk), .rd_clk(rclk), .rst(rst), .wr_en(wr_en), .din(din), .rd_en(rd_en), .dout(dout), .full(full), .empty(empty), .sleep(1'b0), .injectsbiterr(1'b0), .injectdbiterr(1'b0));
endmodule
