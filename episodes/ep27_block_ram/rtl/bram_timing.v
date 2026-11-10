// Episode 27 - what the BRAM's optional output register buys: the same ROM read, then a flip-flop that uses the data.
module t_plain (input wire clk, input wire [9:0] a_in, output reg y);
    reg [9:0] a; wire [11:0] q;
    always @(posedge clk) a <= a_in;
    rom_bram r (.clk(clk), .a(a), .q(q));
    always @(posedge clk) y <= ^(q + {2'b0, a});          // some logic after the memory, as real designs have
endmodule
module t_oreg (input wire clk, input wire [9:0] a_in, output reg y);
    reg [9:0] a; wire [11:0] q;
    always @(posedge clk) a <= a_in;
    rom_bram_oreg r (.clk(clk), .a(a), .q(q));
    always @(posedge clk) y <= ^(q + {2'b0, a});
endmodule
