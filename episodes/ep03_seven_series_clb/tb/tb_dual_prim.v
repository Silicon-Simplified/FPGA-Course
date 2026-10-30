// dual_lut_prim vs the same behavioural references (needs the UNISIM library: xelab ... -L unisims_ver glbl).
`timescale 1ns / 1ps
module tb_dual_prim;
    reg  [4:0] x;
    wire y1, y2;
    integer i, errors = 0;
    dual_lut_prim dut (.x(x), .y1(y1), .y2(y2));
    initial begin
        for (i = 0; i < 32; i = i + 1) begin
            x = i[4:0]; #1;
            if (y1 !== (((x[0]&x[1]) ^ (x[2]|x[3])) ^ x[4])) begin errors = errors + 1; $display("FAIL y1 %b", x); end
            if (y2 !== ((((x[0]^x[2]) & (x[1]|x[3])) | (~x[4] & x[3])))) begin errors = errors + 1; $display("FAIL y2 %b", x); end
        end
        if (errors == 0) $display("PASS: LUT6_2 primitive, both outputs"); else $display("FAILED: %0d errors", errors);
        $finish;
    end
endmodule
