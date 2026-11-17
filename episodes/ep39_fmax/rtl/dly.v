// Episode 39 - experiment 3: a 64-deep, 32-bit delay line.
// MODE 0: shift register WITH a synchronous reset (we expected flip-flops: see the results);  MODE 1: no reset -> the tool packs it into shift-register LUTs (SRL);
// MODE 2: a circular buffer in block RAM (ram_style block), pointer counters; MODE 3: no reset, but shreg_extract = no -> a plain flip-flop chain.
module dly #(parameter MODE = 0) (input wire clk, input wire rst, input wire [31:0] d, output wire [31:0] q);
    generate
        if (MODE == 0) begin : ff
            reg [32*64-1:0] sr;
            always @(posedge clk) if (rst) sr <= 0; else sr <= {sr[32*63-1:0], d};
            assign q = sr[32*64-1 -: 32];
        end else if (MODE == 3) begin : chain
            (* shreg_extract = "no" *) reg [32*64-1:0] sr;
            always @(posedge clk) sr <= {sr[32*63-1:0], d};
            assign q = sr[32*64-1 -: 32];
        end else if (MODE == 1) begin : srl
            reg [32*64-1:0] sr;
            always @(posedge clk) sr <= {sr[32*63-1:0], d};
            assign q = sr[32*64-1 -: 32];
        end else begin : bram
            (* ram_style = "block" *) reg [31:0] mem [0:63];
            reg [5:0] wp = 0; reg [31:0] qq;
            always @(posedge clk) begin mem[wp] <= d; qq <= mem[wp]; wp <= wp + 6'd1; end   // read-before-write: qq is the word written 64 clocks ago
            assign q = qq;
        end
    endgenerate
endmodule
