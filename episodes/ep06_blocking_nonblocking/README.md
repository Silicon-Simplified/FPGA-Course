# Episode 6 — Blocking vs non-blocking assignments (companion code)

Every claim in the video is backed by a run: the Vivado simulator (`xsim`), Verilator lint, and Vivado 2023.2 synthesis
for the Basys 3 part (`xc7a35tcpg236-1`, out-of-context).

| Design | What it shows | Result |
|---|---|---|
| `rtl/reg8_en_rst.v` | the standard clocked template: sync reset + enable, `<=` | **8 flip-flops, 0 LUTs** (reset and enable use the flip-flop's own R and CE pins) |
| `rtl/shift3_nb.v` | 3-stage shift register with `<=` | pulse reaches q3 after **3 clocks** (45 ns); **3 flip-flops** |
| `rtl/shift3_blk.v` | the same with `=` (the bug) | all three outputs rise together at 25 ns, **no delay**; Vivado builds **1 flip-flop** |
| `rtl/swap_nb.v` / `swap_blk.v` | swap two registers | a=1,b=2 → after one clock: `<=` gives (2,1), `=` gives (2,2); Vivado: 8 FF + 8 LUT vs 8 FF + 4 LUT (a different circuit) |
| `rtl/sens_bad.v` / `sens_good.v` | `always @(a)` vs `always @(*)` | simulation: stale output with `@(a)`; Vivado warns `[Synth 8-567] referenced signal 'b' should be on the sensitivity list` and still builds the correct AND (1 LUT2) |
| `rtl/multi_driver.v` | two always blocks driving one reg | `CRITICAL WARNING [Synth 8-6859] multi-driven net`, then `ERROR [DRC MDRV-1] Multiple Driver Nets` |

Verilator lint flags the blocking-assignment designs: `BLKSEQ: Blocking assignment '=' in sequential logic process`.

## Run it
```bash
source <vivado install>/settings64.sh
bash scripts/sim_all.sh                                  # testbenches + reports/wave.vcd
vivado -mode batch -source scripts/synth_all.tcl         # -> reports/synth_summary.csv, reports/synth_all.log
```
**Challenge:** stretch the shift register to 8 stages. Guess how many flip-flops each version uses, then check in Vivado.
