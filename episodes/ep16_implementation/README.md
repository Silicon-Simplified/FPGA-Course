# Episode 16 — Implementation deep dive (companion code)

`rtl/impl_demo.v`: eight 32-bit words summed by an adder tree (169 LUT, 293 FF, 27 CARRY4). `scripts/stages.tcl` runs synthesis, `opt_design`, `place_design`, `phys_opt_design`, `route_design` and a post-route `phys_opt_design` one at a time
(Vivado 2023.2, out-of-context, `xc7z020clg400-1`, the PYNQ-Z2's Zynq-7020) and records the worst setup slack after each step.

| clock | synth | opt | place | phys_opt | route | post-route phys_opt |
|---|---|---|---|---|---|---|
| 8 ns | +1.332 | +1.332 | +0.531 | +0.531 | +0.319 | **+0.319** |
| 7 ns | +0.332 | +0.332 | -0.344 | +0.005 | -0.284 | **-0.217** (6 endpoints fail) |
| 6 ns | -0.668 | -0.668 | -0.533 | -0.390 | -0.599 | **-0.599** |
| 4 ns | -2.668 | -2.668 | -2.802 | -2.572 | -2.998 | **-2.998** |

Also in `reports/`: `placement_*.csv` (slice column/row of every cell after placement; 7 ns: 553 cells in 87 slices), `route_status_*.txt`, `worst_path_*.rpt` (7 ns: 7.195 ns = 3.769 logic + 3.426 routing, 13 levels, 9 CARRY4), `utilization_*.rpt`.
Step times in `stages_*.csv` came from runs that shared one computer (6, 7 and 8 ns ran at the same time), so compare slack, not seconds. Nothing was run on a physical board.

## Run it
```bash
source <vivado install>/settings64.sh
make stages P=7.0
```
**Challenge:** run it at 7.5 ns and find the step where the slack first turns negative.
