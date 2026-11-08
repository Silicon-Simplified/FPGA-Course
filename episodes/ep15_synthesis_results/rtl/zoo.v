// Episode 15 - a zoo of small blocks. Each module is synthesized on its own so we can see what Vivado builds from each piece of Verilog.

// 1. a registered 16-bit adder -> carry chain
module add16 (input wire clk, input wire [15:0] a, b, output reg [15:0] s);
    always @(posedge clk) s <= a + b;
endmodule

// 2. an 8-bit 4:1 mux
module mux4_8 (input wire [7:0] d0, d1, d2, d3, input wire [1:0] sel, output reg [7:0] y);
    always @* case (sel) 2'd0: y = d0; 2'd1: y = d1; 2'd2: y = d2; default: y = d3; endcase
endmodule

// 3. a 32 x 8 ROM, asynchronous read -> LUTs
module rom32x8 (input wire [4:0] a, output reg [7:0] q);
    always @* case (a)
        5'd0: q = 8'h3F; 5'd1: q = 8'h06; 5'd2: q = 8'h5B; 5'd3: q = 8'h4F; 5'd4: q = 8'h66; 5'd5: q = 8'h6D; 5'd6: q = 8'h7D; 5'd7: q = 8'h07;
        5'd8: q = 8'h7F; 5'd9: q = 8'h6F; 5'd10: q = 8'h77; 5'd11: q = 8'h7C; 5'd12: q = 8'h39; 5'd13: q = 8'h5E; 5'd14: q = 8'h79; 5'd15: q = 8'h71;
        default: q = {3'b101, a};
    endcase
endmodule

// 4. a 1024 x 8 RAM with synchronous read -> block RAM
module ram1k_bram (input wire clk, input wire we, input wire [9:0] a, input wire [7:0] d, output reg [7:0] q);
    reg [7:0] mem [0:1023];
    always @(posedge clk) begin if (we) mem[a] <= d; q <= mem[a]; end
endmodule

// 5. the same RAM, but we ask for distributed (LUT) RAM
module ram1k_dist (input wire clk, input wire we, input wire [9:0] a, input wire [7:0] d, output reg [7:0] q);
    (* ram_style = "distributed" *) reg [7:0] mem [0:1023];
    always @(posedge clk) begin if (we) mem[a] <= d; q <= mem[a]; end
endmodule

// 6. an 18 x 18 registered multiplier -> one DSP48E1
module mult18_dsp (input wire clk, input wire signed [17:0] a, b, output reg signed [35:0] p);
    always @(posedge clk) p <= a * b;
endmodule

// 7. the same multiplier, but DSPs are forbidden -> LUTs
(* use_dsp = "no" *)
module mult18_lut (input wire clk, input wire signed [17:0] a, b, output reg signed [35:0] p);
    always @(posedge clk) p <= a * b;
endmodule

// 8. a 32-deep, 1-bit delay line with no reset -> one SRL32
module shreg32 (input wire clk, input wire d, output wire q);
    reg [31:0] s = 0;
    always @(posedge clk) s <= {s[30:0], d};
    assign q = s[31];
endmodule

// 9. the classic accident: an "if" with no "else" in combinational code -> a latch
module latch_bug (input wire en, input wire [3:0] d, output reg [3:0] q);
    always @* if (en) q = d;
endmodule

// 10. a register nobody reads, and one that is stuck at a constant -> trimmed
module trim_demo (input wire clk, input wire [7:0] d, output reg [7:0] q);
    reg [7:0] unused;
    reg       stuck;
    always @(posedge clk) begin
        unused <= d + 8'd1;          // never read
        stuck  <= 1'b0;              // constant
        q      <= d ^ {8{stuck}};    // stuck is always 0, so q == d
    end
endmodule
