// wide7 / wide8 against a behavioural reference, all input combinations.
`timescale 1ns / 1ps
module tb_wide;
    reg  [7:0] x;
    wire y7, y8;
    integer i, errors = 0;
    wide7 d7 (.x(x[6:0]), .y(y7));
    wide8 d8 (.x(x),      .y(y8));
    function ref7(input [6:0] v);
        reg [5:0] a; reg f0, f1;
        begin a = v[5:0]; f0 = ^a; f1 = (a[0]&a[1])|(a[2]&a[3])|(a[4]&a[5]); ref7 = v[6] ? f1 : f0; end
    endfunction
    function ref8(input [7:0] v);
        reg [5:0] a; reg g0,g1,g2,g3;
        begin a = v[5:0]; g0 = ^a; g1 = (a[0]&a[1])|(a[2]&a[3])|(a[4]&a[5]); g2 = (a[0]|a[1])&(a[2]|a[3])&(a[4]|a[5]);
              g3 = (a[0]&a[2]&a[4])|(a[1]&a[3]&a[5]); ref8 = v[7] ? (v[6]?g3:g2) : (v[6]?g1:g0); end
    endfunction
    initial begin
        for (i = 0; i < 256; i = i + 1) begin
            x = i[7:0]; #1;
            if (y7 !== ref7(x[6:0])) begin errors = errors + 1; $display("FAIL wide7 x=%b", x[6:0]); end
            if (y8 !== ref8(x))      begin errors = errors + 1; $display("FAIL wide8 x=%b", x); end
        end
        if (errors == 0) $display("PASS: wide7 and wide8, all combinations"); else $display("FAILED: %0d errors", errors);
        $finish;
    end
endmodule
