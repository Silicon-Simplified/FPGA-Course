#!/usr/bin/env python3
"""Episode 22: generate the pipelined variants of the failing design (24 x 32-bit words -> one sum).
   python3 scripts/gen.py      -> rtl/pipe_N.v for N = 0..4 extra pipeline stages, and rtl/retime_demo.v"""
import os
HERE = os.path.dirname(os.path.abspath(__file__))
LEVELS = [24, 12, 6, 3, 2, 1]          # a balanced adder tree: 5 levels of additions
STAGES = {0: [], 1: [3], 2: [2, 4], 3: [2, 3, 4], 4: [1, 2, 3, 4]}     # which tree levels get a register bank


def gen(n, regs):
    L = [f"// Episode 22 - the failing design with {n} extra pipeline stage(s): registers after tree level(s) {regs if regs else 'none'}.",
         f"// 24 x 32-bit words -> balanced adder tree (5 levels) -> sum register -> xor -> dout. Latency = {n + 1} cycles after the shift register.",
         f"module pipe_{n} (input wire clk, input wire din, output wire dout);",
         "    reg [767:0] sh = 0;", "    always @(posedge clk) sh <= {sh[766:0], din};"]
    prev = [f"sh[{32 * i + 31}:{32 * i}]" for i in range(24)]
    for lv in range(1, 6):
        cur = []
        size = LEVELS[lv]
        kind = "reg" if lv in regs else "wire"
        for i in range(size):
            a = prev[2 * i]
            b = prev[2 * i + 1] if 2 * i + 1 < len(prev) else None
            name = f"l{lv}_{i}"
            expr = f"{a} + {b}" if b else a
            if kind == "reg":
                L.append(f"    reg [36:0] {name} = 0; always @(posedge clk) {name} <= {expr};")
            else:
                L.append(f"    wire [36:0] {name} = {expr};")
            cur.append(name)
        prev = cur
    L += [f"    reg [36:0] sum = 0; always @(posedge clk) sum <= {prev[0]};",
          "    reg x = 0; always @(posedge clk) x <= ^sum;", "    assign dout = x;", "endmodule", ""]
    return "\n".join(L)


for n, regs in STAGES.items():
    open(os.path.join(HERE, "..", "rtl", f"pipe_{n}.v"), "w").write(gen(n, regs))

# retiming demo: the SAME combinational tree as pipe_0, followed by 3 extra register stages that a retiming synthesis may move backwards
r = gen(0, []).replace("module pipe_0", "module retime_demo").replace("extra pipeline stage(s)", "extra pipeline stage(s) + 3 trailing register stages")
r = r.replace("    reg x = 0; always @(posedge clk) x <= ^sum;", "    reg [36:0] t1 = 0, t2 = 0, t3 = 0; always @(posedge clk) begin t1 <= sum; t2 <= t1; t3 <= t2; end\n    reg x = 0; always @(posedge clk) x <= ^t3;")
open(os.path.join(HERE, "..", "rtl", "retime_demo.v"), "w").write(r)
