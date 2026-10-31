# Episode 5 — Verilog basics: think in hardware (companion code)

A 4-bit ALU on the PYNQ-Z2, plus the experiments behind every claim in the video. Everything was simulated with the Vivado
simulator and synthesised / implemented with Vivado 2023.2 for `xc7z020clg400-1` (the PYNQ-Z2's Zynq-7020).

| File | What it shows | Result |
|---|---|---|
| `rtl/adder4.v` | a small reusable module (ports, `assign`, explicit widths) | used inside the ALU |
| `rtl/alu4.v` | 8-operation ALU: `case` in a combinational `always @(*)`, one `adder4` instance for ADD and SUB | passes all **2048** (a, b, op) combinations |
| `rtl/alu4_reg.v` | the same ALU with registered outputs | **6 flip-flops** (the combinational one has **0**) |
| `rtl/alu_top.v` + `constraints/pynq_z2.xdc` | PYNQ-Z2 top level: Pmod pins in, LEDs out | full build to a bitstream: **15 LUTs, 0 flip-flops, 17 pins, 4,045,667-byte .bit** |
| `rtl/latch_bug.v` / `latch_fixed.v` | `if` without `else` in a combinational block | bug: **4 latches (LDCE), 0 LUTs**; fix: 4 LUT2, no latches |
| `rtl/order_a.v` / `order_b.v` | same `assign`s in reverse order | both: **1 LUT4, identical INIT `8FF8`** |
| `rtl/ops_demo.v` | every operator family | values verified by `tb/tb_ops.v` |

## PYNQ-Z2 usage
The PYNQ-Z2 has only two switches, so the inputs come from the Pmod headers (jumper wire to 3.3 V = 1, to GND = 0; unconnected pins read 0 through weak pull-downs):
`a[3:0]` = Pmod A pins 0-3, `b[3:0]` = Pmod A pins 4-7, `op[2:0]` = Pmod B pins 0-2 (000 ADD, 001 SUB, 010 AND, 011 OR, 100 XOR, 101 NOT a, 110 SHL, 111 SHR)
`led[3:0]` = LD0-LD3 result, `led_zero` = LD4 green, `led_carry` = LD5 green (for SUB, carry = 1 means no borrow, i.e. a ≥ b)

## Run it
```bash
source <vivado install>/settings64.sh
bash scripts/lint.sh                                   # Verilator
bash scripts/sim_all.sh                                # testbenches (xsim)
vivado -mode batch -source scripts/synth_all.tcl       # -> reports/synth_summary.csv (+ the latch warning in reports/synth_all.log)
vivado -mode batch -source scripts/build_top.tcl       # -> build/alu_top.bit
```
Pin names in `pynq_z2.xdc` are copied from the official PYNQ-Z2 constraints (Xilinx/PYNQ `boards/Pynq-Z2/base/vivado/constraints/base.xdc`, tag v2.7.0); Vivado checked that they are legal for the package. Not tested on a physical board.
**Challenge:** add a ninth operation (for example "increment a") by widening `op` to 4 bits, and update the testbench.
