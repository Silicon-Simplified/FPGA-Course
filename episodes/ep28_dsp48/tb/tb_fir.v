// Episode 28 - drive the FIR with a stimulus file and write its output (compared with a numpy reference by scripts/check_fir.py).
`timescale 1ns/1ps
module tb_fir;
    reg clk = 0; always #4 clk = ~clk;
    reg signed [15:0] x = 0; wire signed [34:0] y;
    fir8 dut (.clk(clk), .x(x), .y(y));
    integer fi, fo, r, v;
    initial begin
        fi = $fopen("fir_in.txt", "r"); fo = $fopen("fir_out.txt", "w");
        while (!$feof(fi)) begin
            r = $fscanf(fi, "%d\n", v);
            @(negedge clk); x = v;
            @(posedge clk); #1 $fdisplay(fo, "%0d", $signed(y));
        end
        repeat (6) begin @(negedge clk); x = 0; @(posedge clk); #1 $fdisplay(fo, "%0d", $signed(y)); end
        $fclose(fi); $fclose(fo); $finish;
    end
endmodule
