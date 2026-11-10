// Episode 27 - read-during-write and read latency, measured in simulation.
`timescale 1ns/1ps
module tb_rw;
    reg clk = 0; always #5 clk = ~clk;
    reg we = 0; reg [9:0] a = 0; reg [7:0] d = 0;
    wire [7:0] q_rf, q_wf, q_nc;
    ram_readfirst  rf (.clk(clk), .we(we), .a(a), .d(d), .q(q_rf));
    ram_writefirst wf (.clk(clk), .we(we), .a(a), .d(d), .q(q_wf));
    ram_nochange   nc (.clk(clk), .we(we), .a(a), .d(d), .q(q_nc));
    // latency: a ROM address changes at cycle 0; when does the data change?
    reg [9:0] ra = 0; wire [11:0] q1, q2;
    rom_bram      r1 (.clk(clk), .a(ra), .q(q1));
    rom_bram_oreg r2 (.clk(clk), .a(ra), .q(q2));
    integer i;
    initial begin
        // preload address 5 with 0x11 and address 9 with 0x77 (write cycle, then read them back so q holds 0x77)
        @(negedge clk); we = 1; a = 10'd5; d = 8'h11;
        @(negedge clk); a = 10'd9; d = 8'h77;
        @(negedge clk); we = 0; a = 10'd9;                    // read 0x77: q = 0x77 in all three
        @(negedge clk);
        // now write 0xAA to address 5 and look at q after the clock edge: the read-during-write cycle
        we = 1; a = 10'd5; d = 8'hAA;
        @(negedge clk);
        $display("RW write 0xAA over old 0x11 at the same address; the output after that clock edge:  read_first=%h  write_first=%h  no_change=%h", q_rf, q_wf, q_nc);
        we = 0; a = 10'd5;
        @(negedge clk);
        $display("RW next cycle, reading the address again:                                             read_first=%h  write_first=%h  no_change=%h", q_rf, q_wf, q_nc);
        // latency
        @(negedge clk); ra = 10'd256;                         // sine[256] = 0x7FF
        for (i = 1; i <= 3; i = i + 1) begin
            @(negedge clk);
            $display("LAT address changed to 256; after %0d clock edge(s): rom_bram=%h  rom_bram_oreg=%h", i, q1, q2);
        end
        $finish;
    end
endmodule
