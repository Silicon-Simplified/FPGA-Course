// Episode 41 - digital down-converter: 12-bit input at 100 MHz -> NCO + mixer -> CIC (/50) -> 31-tap FIR (/4) -> 16-bit I and Q at 500 kHz.
module ddc_top #(parameter CICW = 33) (input wire clk, input wire rst, input wire signed [11:0] x, input wire [31:0] inc, output wire signed [15:0] out_i, output wire signed [15:0] out_q, output wire out_valid);
    wire signed [15:0] cs, nsn;
    nco n0 (.clk(clk), .rst(rst), .inc(inc), .cos_o(cs), .nsin_o(nsn));
    reg signed [11:0] xd; reg signed [15:0] mi, mq;
    wire signed [27:0] pi = xd * cs, pq = xd * nsn;               // full-width products (a 16-bit context would silently truncate them)              // the input is delayed one clock to line up with the NCO output
    always @(posedge clk) begin
        if (rst) begin xd <= 0; mi <= 0; mq <= 0; end
        else begin xd <= x; mi <= pi >>> 11; mq <= pq >>> 11; end
    end
    wire signed [15:0] ci, cq; wire cv, cvq;
    cic_decim #(CICW) ki (.clk(clk), .rst(rst), .din(mi), .dout(ci), .dvalid(cv));
    cic_decim #(CICW) kq (.clk(clk), .rst(rst), .din(mq), .dout(cq), .dvalid(cvq));
    wire fv, fvq;
    fir_decim fi (.clk(clk), .rst(rst), .in_valid(cv), .din(ci), .dout(out_i), .dvalid(fv));
    fir_decim fq (.clk(clk), .rst(rst), .in_valid(cvq), .din(cq), .dout(out_q), .dvalid(fvq));
    assign out_valid = fv;
endmodule
