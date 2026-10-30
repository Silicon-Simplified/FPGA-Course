# Episode 5 — Verilog basics: think in hardware (companion code)

A 4-bit ALU on the Basys 3, plus the experiments behind every claim in the video. Everything was simulated with the Vivado
simulator and synthesised / implemented with Vivado 2023.2 for `xc7a35tcpg236-1`.

| File | What it shows | Result |
|---|---|---|
| `rtl/adder4.v` | a small reusable module (ports, `assign`, explicit widths) | used inside the ALU |
| `rtl/alu4.v` | 8-operation ALU: `case` in a combinational `always @(*)`, one `adder4` instance for ADD and SUB | passes all **2048** (a, b, op) combinations |
| `rtl/alu4_reg.v` | the same ALU with registered outputs | **6 flip-flops** (the combinational one has **0**) |
| `rtl/alu_top.v` + `constraints/basys3.xdc` | Basys 3 top level: switches in, LEDs out | full build to a bitstream: **15 LUTs, 0 flip-flops, 17 pins, 2,192,115-byte .bit** |
| `rtl/latch_bug.v` / `latch_fixed.v` | `if` without `else` in a combinational block | bug: **4 latches (LDCE), 0 LUTs**; fix: 4 LUT2, no latches |
| `rtl/order_a.v` / `order_b.v` | same `assign`s in reverse order | both: **1 LUT4, identical INIT `8FF8`** |
| `rtl/ops_demo.v` | every operator family | values verified by `tb/tb_ops.v` |

## Basys 3 usage
`sw[3:0]` = a, `sw[7:4]` = b, `sw[10:8]` = op (000 ADD, 001 SUB, 010 AND, 011 OR, 100 XOR, 101 NOT a, 110 SHL, 111 SHR)
`led[3:0]` = result, `led[4]` = zero flag, `led[5]` = carry (for SUB, carry = 1 means no borrow, i.e. a ≥ b)

## Run it
```bash
source <vivado install>/settings64.sh
bash scripts/lint.sh                                   # Verilator
bash scripts/sim_all.sh                                # testbenches (xsim)
vivado -mode batch -source scripts/synth_all.tcl       # -> reports/synth_summary.csv (+ the latch warning in reports/synth_all.log)
vivado -mode batch -source scripts/build_top.tcl       # -> build/alu_top.bit
```
Pin names in `basys3.xdc` are from Digilent's Basys 3 master XDC; Vivado checked that they are legal for the package.
**Challenge:** add a ninth operation (for example "increment a") by widening `op` to 4 bits, and update the testbench.
