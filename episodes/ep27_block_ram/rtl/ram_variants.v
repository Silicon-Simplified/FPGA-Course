// Episode 27 - the same memory written in different ways. The way you write it decides what Vivado builds.

// 1024 x 12 sine ROM, registered (synchronous) read, initialised from a file -> block RAM
module rom_bram (input wire clk, input wire [9:0] a, output reg [11:0] q);
    reg [11:0] mem [0:1023];
    initial $readmemh("rtl/sine1024.hex", mem);
    always @(posedge clk) q <= mem[a];
endmodule

// the same ROM with an extra output register (BRAM's optional output register: faster clock-to-out, one more cycle of latency)
module rom_bram_oreg (input wire clk, input wire [9:0] a, output reg [11:0] q);
    reg [11:0] mem [0:1023];
    reg [11:0] q1;
    initial $readmemh("rtl/sine1024.hex", mem);
    always @(posedge clk) begin q1 <= mem[a]; q <= q1; end
endmodule

// the same ROM forced into LUTs, asynchronous read (combinational)
module rom_dist (input wire [9:0] a, output wire [11:0] q);
    (* ram_style = "distributed" *) reg [11:0] mem [0:1023];
    initial $readmemh("rtl/sine1024.hex", mem);
    assign q = mem[a];
endmodule

// 1024 x 8 single-port RAM, three read-during-write behaviours
module ram_readfirst (input wire clk, input wire we, input wire [9:0] a, input wire [7:0] d, output reg [7:0] q);
    reg [7:0] mem [0:1023];
    always @(posedge clk) begin if (we) mem[a] <= d; q <= mem[a]; end                    // READ_FIRST: q gets the OLD data
endmodule
module ram_writefirst (input wire clk, input wire we, input wire [9:0] a, input wire [7:0] d, output reg [7:0] q);
    reg [7:0] mem [0:1023];
    always @(posedge clk) begin if (we) begin mem[a] <= d; q <= d; end else q <= mem[a]; end   // WRITE_FIRST: q gets the NEW data
endmodule
module ram_nochange (input wire clk, input wire we, input wire [9:0] a, input wire [7:0] d, output reg [7:0] q);
    reg [7:0] mem [0:1023];
    always @(posedge clk) begin if (we) mem[a] <= d; else q <= mem[a]; end               // NO_CHANGE: q keeps its last value while writing
endmodule

// true dual-port RAM: two independent ports (different addresses, same clock here)
module ram_tdp (input wire clk, input wire wea, input wire [9:0] aa, input wire [7:0] da, output reg [7:0] qa,
                input wire web, input wire [9:0] ab, input wire [7:0] db, output reg [7:0] qb);
    reg [7:0] mem [0:1023];
    always @(posedge clk) begin if (wea) mem[aa] <= da; qa <= mem[aa]; end
    always @(posedge clk) begin if (web) mem[ab] <= db; qb <= mem[ab]; end
endmodule

// direct digital synthesis: a 32-bit phase accumulator addresses the sine ROM; f_out = f_clk * K / 2^32
module dds (input wire clk, input wire [31:0] k, output wire signed [11:0] sine);
    reg [31:0] phase = 0;
    always @(posedge clk) phase <= phase + k;
    wire [11:0] q;
    rom_bram_oreg r (.clk(clk), .a(phase[31:22]), .q(q));
    assign sine = q;
endmodule
