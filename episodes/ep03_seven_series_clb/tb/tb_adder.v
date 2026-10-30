// Exhaustive: all 65,536 combinations of two 8-bit operands, for both adder variants.
`timescale 1ns / 1ps
module tb_adder;
    reg  [7:0] a, b;
    wire [7:0] s;
    wire [8:0] sc;
    integer i, errors = 0;
    adder    #(.W(8)) dut  (.a(a), .b(b), .s(s));
    adder_co #(.W(8)) dutc (.a(a), .b(b), .s(sc));
    initial begin
        for (i = 0; i < 65536; i = i + 1) begin
            {a, b} = i[15:0];
            #1;
            if (s  !== ((a + b) & 8'hFF)) begin errors = errors + 1; if (errors < 5) $display("FAIL adder    a=%0d b=%0d", a, b); end
            if (sc !== ({1'b0, a} + {1'b0, b})) begin errors = errors + 1; if (errors < 5) $display("FAIL adder_co a=%0d b=%0d", a, b); end
        end
        if (errors == 0) $display("PASS: adder and adder_co, all 65536 cases"); else $display("FAILED: %0d errors", errors);
        $finish;
    end
endmodule
