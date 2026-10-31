// Silicon Simplified - FPGA Course, Episode 10
// A register slice (one pipeline stage) for a valid/ready stream. Ports are two interfaces instead of 6 loose wires.
module stream_slice (
    input  logic       clk,
    input  logic       rst,
    if_stream.snk      in,
    if_stream.src      out
);
    logic       v;
    logic [7:0] d;
    assign in.ready  = !v || out.ready;
    assign out.valid = v;
    assign out.data  = d;
    always_ff @(posedge clk) begin
        if (rst)           v <= 1'b0;
        else if (in.ready) begin v <= in.valid; d <= in.data; end
    end
endmodule
