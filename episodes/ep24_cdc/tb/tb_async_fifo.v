// Episode 24 - the async FIFO between unrelated clocks (write 5 ns, read 13 ns): 3000 words, random write gaps, check order / no loss / no duplicates.
`timescale 1ns/1ps
module tb_async_fifo;
    reg wclk = 0, rclk = 0;
    always #2.5 wclk = ~wclk;
    always #6.5 rclk = ~rclk;
    wire full, empty; wire [7:0] rdata;
    reg winc = 0; reg [7:0] wdata = 0;
    reg rinc = 0;
    async_fifo #(8, 4) dut (.wclk(wclk), .winc(winc), .wdata(wdata), .wfull(full), .rclk(rclk), .rinc(rinc), .rdata(rdata), .rempty(empty));
    reg [31:0] lfsr = 32'h1234_5678;
    integer sent = 0, got = 0, errors = 0, full_seen = 0, empty_seen = 0;
    reg [7:0] expect_v = 0;
    always @(posedge wclk) begin
        lfsr <= {lfsr[30:0], lfsr[31] ^ lfsr[21] ^ lfsr[1] ^ lfsr[0]};
        if (full) full_seen = full_seen + 1;
        if (winc && !full) begin sent = sent + 1; winc <= 1'b0; end                  // the word was accepted this cycle
        else if (!winc && sent < 3000 && lfsr[1:0] != 2'b00) begin winc <= 1'b1; wdata <= sent[7:0]; end   // otherwise hold until accepted
    end
    always @(posedge rclk) begin
        rinc <= !empty && (lfsr[5] | lfsr[9]);
        if (empty) empty_seen = empty_seen + 1;
        if (rinc && !empty) begin
            if (rdata !== expect_v) errors = errors + 1;
            expect_v = expect_v + 8'd1; got = got + 1;
        end
        if (got == 3000) begin
            if (errors == 0) $display("FIFO_PASS words=%0d errors=0 (full seen %0d times, empty seen %0d times)", got, full_seen, empty_seen);
            else $display("FIFO_FAIL errors=%0d", errors);
            $finish;
        end
    end
    initial begin #3000000; $display("FIFO_TIMEOUT sent=%0d got=%0d", sent, got); $finish; end
endmodule
