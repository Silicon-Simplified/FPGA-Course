# Episode 10 — SystemVerilog for synthesis (companion code)

Every claim in the video is backed by a run: Verilator lint, the Vivado simulator (`xvlog -sv`, `xelab`, `xsim`) and Vivado 2023.2 synthesis for the PYNQ-Z2 part (`xc7z020clg400-1`, out-of-context).

| Design | What it shows | Result |
|---|---|---|
| `rtl/latch_comb.sv` | `always_comb` that forgets to assign `q` | Verilator `LATCH: Latch inferred for signal 'q'`; Vivado `[Synth 8-327] inferring latch`, **4 × LDCE** |
| `rtl/blk_ff.sv` | `always_ff` with blocking `=` | Verilator `BLKSEQ` on both lines; Vivado merges the registers: `[Synth 8-6014]` q2_reg removed, **1 × FDRE** |
| `rtl/multi_drv.sv` | two `always_ff` driving one variable | `xvlog`: `ERROR [VRFC 10-3818] variable 'q' is driven by invalid combination of procedural drivers` (in Verilog, only Vivado's `DRC MDRV-1` finds it, after synthesis) |
| `rtl/fsm_traffic_sv.sv` | the Episode 8 traffic light with an enum, `always_ff`/`always_comb`, `unique case` | same hardware as the Verilog version: **13 LUTs, 6 FF**; 1200 clocks compared (steady + random ticks): 0 mismatches. The log prints the state names |
| `rtl/alu_pkg.sv`, `rtl/alu4_sv.sv` | package with an enum op and a packed-struct result | exhaustive 2048 vectors: 0 errors vs reference, 0 mismatches vs the Verilog ALU. **19 LUTs** (Verilog: 20) |
| `rtl/if_stream.sv`, `rtl/stream_slice.sv` | interface + modports, valid/ready register slice | random-stall test with a queue scoreboard: **1887 words in, 1887 out, 0 errors**, output blocked 1555 cycles. Vivado: **9 FF, 3 LUT** |

## Run it
```bash
source <vivado install>/settings64.sh
bash scripts/lint.sh                        # Verilator (the three "bad" files are supposed to warn)
bash scripts/sim_all.sh                     # SystemVerilog self-checking testbenches
bash scripts/messages.sh                    # compiler message for the multi-driver file
vivado -mode batch -source scripts/synth_all.tcl     # -> reports/synth_summary.csv
```
**Challenge:** rewrite the Episode 8 debouncer in SystemVerilog and compare its flip-flop count with the Verilog version (24).
