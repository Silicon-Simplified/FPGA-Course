// Single-event-upset test: force the illegal state 6 into both rings between clock edges.
`timescale 1ns / 1ps
module tb_safe;
    reg clk = 0, rst = 1, go = 1;
    wire busy_u, busy_s;
    integer errors = 0;
    fsm_unsafe u (.clk(clk), .rst(rst), .go(go), .busy(busy_u));
    fsm_safe   s (.clk(clk), .rst(rst), .go(go), .busy(busy_s));
    wire [2:0] unsafe_state = u.state;
    wire [2:0] safe_state   = s.state;
    always #5 clk = ~clk;
    initial begin
        $dumpfile("wave.vcd"); $dumpvars(0, tb_safe);
        #12 rst = 0;
        #50;                                       // 62 ns: running normally
        u.state = 3'd6; s.state = 3'd6;            // bit flip into an illegal state
        #4 $display("SEU @66ns  unsafe=%0d safe=%0d", u.state, s.state);
        #60;                                       // 126 ns: several clocks later
        $display("SEU @126ns unsafe=%0d safe=%0d", u.state, s.state);
        if (u.state !== 3'd6) begin errors = errors + 1; $display("FAIL: unsafe FSM should be stuck in state 6"); end
        if (s.state > 3'd4)   begin errors = errors + 1; $display("FAIL: safe FSM did not recover"); end
        #100;
        if (s.state === 3'd6 || (s.state > 3'd4)) begin errors = errors + 1; $display("FAIL: safe FSM illegal"); end
        if (errors == 0) $display("PASS: the safe FSM recovers from an illegal state, the unsafe one is stuck forever");
        else $display("FAILED: %0d errors", errors);
        $finish;
    end
endmodule
