// Episode 31 - an 8-bit SPI master for all four modes. SCLK = clk / (2 * DIV). CPOL = idle level of SCLK; CPHA = 0: sample on the leading edge, 1: sample on the trailing edge.
module spi_master #(parameter DIV = 12, CPOL = 0, CPHA = 0) (
    input wire clk, input wire start, input wire [7:0] tx, output reg [7:0] rx = 0, output wire busy, output reg done = 0,
    output reg sclk = CPOL, output reg mosi = 0, input wire miso, output reg cs_n = 1);
    reg [15:0] cnt = 0; reg [4:0] edges = 0; reg [7:0] sh_out = 0, sh_in = 0; reg active = 0, last = 0;
    assign busy = active;
    always @(posedge clk) begin
        done <= 0;
        if (!active) begin
            if (start) begin
                active <= 1; cs_n <= 0; cnt <= 0; edges <= 0; last <= 0; sclk <= CPOL;
                if (CPHA == 0) begin mosi <= tx[7]; sh_out <= {tx[6:0], 1'b0}; end      // CPHA 0: the first bit is on MOSI before the first edge
                else sh_out <= tx;
            end
        end else if (cnt == DIV - 1) begin
            cnt <= 0;
            if (last) begin cs_n <= 1; active <= 0; done <= 1; rx <= sh_in; end
            else begin
                sclk <= ~sclk; edges <= edges + 1'b1;
                if (!edges[0]) begin                                                      // leading edge
                    if (CPHA == 0) sh_in <= {sh_in[6:0], miso};
                    else begin mosi <= sh_out[7]; sh_out <= {sh_out[6:0], 1'b0}; end
                end else begin                                                            // trailing edge
                    if (CPHA == 1) sh_in <= {sh_in[6:0], miso};
                    else begin mosi <= sh_out[7]; sh_out <= {sh_out[6:0], 1'b0}; end
                    if (edges == 5'd15) last <= 1;
                end
            end
        end else cnt <= cnt + 1'b1;
    end
endmodule
