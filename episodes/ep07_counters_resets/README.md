# Episode 7 — Counters, enables and resets done right (companion code)

Every claim in the video is backed by a run: the Vivado simulator (`xsim`), Verilator lint, Vivado 2023.2 synthesis
(out-of-context) and full implementation for the PYNQ-Z2 part (`xc7z020clg400-1`, 125 MHz clock).

| Design | What it shows | Result |
|---|---|---|
| `rtl/cnt8_sync.v` / `cnt8_async.v` | 8-bit counter with sync vs async reset + enable | reset asserted at 82 ns (between edges): async q = 0 at once, sync q still 5 until the 85 ns edge. Vivado: **8 × FDRE** vs **8 × FDCE**, same 9 LUTs |
| `rtl/shreg_rst.v` / `shreg_arst.v` / `shreg_norst.v` | 8-bit × 32-deep delay line with reset on every stage vs no reset | sync reset: **47 FF + 8 LUT + 8 SRLC32E**; no reset: **16 FF + 0 LUT + 8 SRLC32E**; identical output once full (testbench) |
| `rtl/rst_sync.v` | reset synchronizer (assert async, release sync) | request ends 37 ns → `srst` falls at 55 ns (a clock edge); new request at 68 ns → `srst` rises at once; ends 82 ns → falls at 95 ns. Vivado: **2 × FDPE**, 0 LUTs |
| `rtl/tick_gen.v` | one-cycle tick every N clocks | N = 125,000,000 (1 s at 125 MHz) → **27 flip-flops**; simulation with N = 20: 8 ticks, LED counter = 8 |
| `rtl/blink_en.v` vs `rtl/blink_div.v` | clock enable vs divided clock | identical in simulation; after implementation both: **10 LUTs, 31 flip-flops, 1 BUFG** — but `blink_div` has **4 × `TIMING-17` Critical Warning** (non-clocked sequential cell), `check_timing` no_clock = 4, 4 endpoints never timed. `blink_en`: all 31 flip-flops on `sys_clk`, 0 warnings of that kind |

Reports: `reports/synth_summary.csv`, `reports/top_blink_*_{check_timing,clock_networks,clocks,methodology,timing,utilization,cdc}.rpt`, `reports/sim_output.txt`, `reports/lint_output.txt`.

## Run it
```bash
source <vivado install>/settings64.sh
bash scripts/lint.sh                                    # Verilator
bash scripts/sim_all.sh                                 # testbenches + reports/wave_*.vcd
python3 scripts/vcd2json.py reports/wave_counter.vcd reports/wave_counter.json   # (used by the animation)
vivado -mode batch -source scripts/synth_all.tcl        # -> reports/synth_summary.csv
vivado -mode batch -source scripts/impl_blink.tcl       # full flow for both blinkers (takes a while)
```
`constraints/pynq_z2_blink.xdc` lists the PYNQ-Z2 pins (LEDs and button from the official PYNQ-Z2 constraints, clock pin H16; legality checked by Vivado; not tested on a board).

**Challenge:** build a 100 Hz tick generator from the 125 MHz clock (`tick_gen` with `N = 1_250_000`). Guess how many flip-flops it needs, then check in Vivado.
