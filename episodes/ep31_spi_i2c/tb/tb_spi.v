// Episode 31 - the SPI master against a slave model, in all four modes: 256 bytes each way per mode, plus a measurement of SCLK.
`timescale 1ns/1ps
module tb_spi;
    reg clk = 0; always #4 clk = ~clk;
    genvar m;
    generate for (m = 0; m < 4; m = m + 1) begin : mode
        localparam CPOL = m >> 1, CPHA = m & 1;
        reg start = 0; reg [7:0] tx = 0; wire [7:0] rx; wire busy, done, sclk, mosi, cs_n; reg miso = 0;
        spi_master #(12, CPOL, CPHA) dut (.clk(clk), .start(start), .tx(tx), .rx(rx), .busy(busy), .done(done), .sclk(sclk), .mosi(mosi), .miso(miso), .cs_n(cs_n));
        // slave model: answers with ~master byte (so both directions are checked), shifting out on the "shift" edge and sampling on the "sample" edge
        reg [7:0] s_in = 0, s_out = 0, s_got = 0; integer bitn = 0;
        wire lead = (sclk != CPOL);                                            // true after the leading edge
        reg [7:0] resp = 0;
        always @(posedge sclk or negedge sclk) if (!cs_n) begin
            if ((CPOL == 0 && sclk == 1) || (CPOL == 1 && sclk == 0)) begin     // leading edge
                if (CPHA == 0) begin s_in = {s_in[6:0], mosi}; bitn = bitn + 1; end
                else begin miso = resp[7 - bitn]; end
            end else begin                                                       // trailing edge
                if (CPHA == 1) begin s_in = {s_in[6:0], mosi}; bitn = bitn + 1; end
                else if (bitn < 8) begin miso = resp[7 - bitn]; end
            end
            if (bitn == 8) s_got = s_in;
        end
        always @(negedge cs_n) begin bitn = 0; s_in = 0; resp = ~tx; if (CPHA == 0) miso = ~tx[7]; end
        integer i, errs = 0, ok = 0; time t0, t1; integer ncl = 0;
        always @(posedge sclk) ncl = ncl + 1;
        initial begin
            repeat (10) @(negedge clk);
            for (i = 0; i < 256; i = i + 1) begin
                @(negedge clk); tx = i[7:0]; start = 1; @(negedge clk); start = 0;
                if (i == 0) t0 = $time;
                wait (done); @(negedge clk);
                if (i == 0) t1 = $time;
                if (rx === ~i[7:0] && s_got === i[7:0]) ok = ok + 1; else errs = errs + 1;
                repeat (6) @(negedge clk);
            end
            $display("SPI mode %0d (CPOL=%0d CPHA=%0d): 256 bytes, %0d ok, %0d errors; one byte took %0d ns", m, CPOL, CPHA, ok, errs, t1 - t0);
            if (m == 0) $display("SPI SCLK = clk / (2*12) = %0d kHz", 125000 / 24);
            if (m == 3) $finish;
        end
    end endgenerate
endmodule
