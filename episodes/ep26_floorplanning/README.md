# Episode 26 — Physical design: floorplanning, Pblocks and incremental compile (companion code)

`rtl/fp_demo.v`: four identical lanes (256-bit shift register, 8-word adder tree in two pipeline stages) sharing only the clock and one input bit; `rtl/fp_demo_mod.v` changes one inverter in lane 3.
PYNQ-Z2 `xc7z020clg400-1`, Vivado 2023.2, clock 5 ns. `scripts/fp.tcl` runs one flow per floorplan (hierarchy kept so lanes can be put in Pblocks).

| run | result |
|---|---|
| device (`reports/device_geometry.txt`) | 6 clock regions (2 × 3), 13,300 slices, slice grid X0–113 / Y0–149 |
| `auto` (no Pblocks) | WNS **+0.288**, WHS +0.007; the 4 lanes form a tight cluster on the right (each about 10 × 11 slices) |
| `regions` (one Pblock = one clock region per lane) | WNS **+0.224**, WHS +0.099; lane 0 is placed at X38–49, Y40–49, far from the others |
| `tight` (Pblock `SLICE_X0Y0:SLICE_X4Y9`, lane needs 79 slices) | **not an error**: WARNING 12-4775 (aligned to 60 sites), WARNING Place 30-769 (up to 8 registers per slice), DRC **UTLZ-3 Warning**; `IS_SOFT = 1`: **203 of 502** lane-0 leaf cells ended up outside the Pblock; WNS +0.337 (`reports/tight_pblock.txt`, `drc_tight.rpt`) |
| `mod_full` (fresh compile of the one-inverter change) | WNS +0.242; place 18.1 s, place + route 45.1 s |
| `mod_incr` (`read_checkpoint -incremental` the `auto` result) | WNS +0.288; place **2.4 s**, place + route **24.9 s**; 99.94% of nets fully reused, 100% of instances reused (`reports/incremental_summary.txt`) |

Notes: Pblocks do not make timing better by themselves; the automatic placement was better here. The times come from runs that shared one computer. The incremental flow printed an `iphys_opt_design` "Too many positional options" error because this project's path contains spaces; the flow still completed, but use a path without spaces.
Nothing was run on a physical board.

## Run it
```bash
source <vivado install>/settings64.sh
make auto regions tight
make incremental
```
**Challenge:** set `IS_SOFT` to 0 on the too-small Pblock and see what Vivado does.
