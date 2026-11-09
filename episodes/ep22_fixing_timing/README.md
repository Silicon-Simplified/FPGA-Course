# Episode 22 — Fixing timing: pipelining, retiming, max_fanout (companion code)

The failing design of Episode 21 (24 x 32-bit words summed in one cycle) at the PYNQ-Z2's 125 MHz clock (8 ns), `xc7z020clg400-1`, Vivado 2023.2, out-of-context. **The clock is constrained before synthesis** (`constraints/clk.xdc` is read first).
`scripts/gen.py` generates `rtl/pipe_0..4.v` (a balanced adder tree with 0–4 extra register stages) and `rtl/retime_demo.v`; `scripts/fix.tcl` runs one variant; `scripts/run_all.sh` runs everything.

| variant | WNS ns | failing | FF | LUT | worst path | note |
|---|---|---|---|---|---|---|
| flat adder chain (`fail_demo`), clock first | -1.359 | 27 / 806 | 807 | 716 | 9.384 ns | in Episode 21 the clock was created *after* synthesis: -2.112 |
| balanced tree, 0 extra stages | -0.679 | 23 | 806 | 712 | 8.657 | |
| + strongest directives (Explore / ExtraTimingOpt / AggressiveExplore / Explore) | -0.762 | 21 | 806 | 712 | 8.740 | tool effort does not help |
| 1 extra stage | +0.215 | 0 | 911 | 447 | 7.763 | |
| 2 extra stages | +2.698 | 0 | 1081 | 543 | 5.280 | |
| 3 extra stages | +2.764 | 0 | 1186 | 576 | 5.214 | |
| 4 extra stages | +4.547 | 0 | 1582 | 762 | 3.415 | |
| same adders + 3 register stages, plain | -0.921 | 25 | 843 | 731 | 8.899 | `retime_demo` |
| same, `-global_retiming on` | +2.169 | 0 | 1203 | 680 | 5.778 | logic levels 15 → 6 |
| 3000 FFs on one enable, 3 ns clock | +0.088 | 0 | 3020 | 21 | 2.905 | `fanout_demo` |
| same with `(* max_fanout = 50 *)` | +0.137 | 0 | 3062 | 21 | 2.808 | driver copied: +42 FF |

`tb/tb_pipe.v` (Verilator, `reports/sim_output.txt`): the sums of `pipe_1..4` equal `pipe_0`'s sum delayed by 1..4 cycles (4400 comparisons, PASS; a deliberately misaligned comparison fails).
Notes: `-retiming` is deprecated in 2023.2 (use `-global_retiming on`), and retiming does nothing unless the clock constraint exists before synthesis ("No global retiming is needed without any clock constraint").
Nothing was run on a physical board.

## Run it
```bash
source <vivado install>/settings64.sh
make gen
make run          # about 8 minutes
```
**Challenge:** put the pipeline registers at levels 1 and 3, predict the slack, then run it (edit `STAGES` in `scripts/gen.py`).
