# Episode 14 — XDC constraints from zero (companion code)

One design (`rtl/blinky.v`, from Episode 13) built for the PYNQ-Z2 (`xc7z020clg400-1`, 125 MHz) with different constraints. `scripts/experiments.sh` runs everything below with Vivado 2023.2.

| experiment | result (`reports/`) |
|---|---|
| bank voltage: `led[2]` set to LVCMOS18 while `clk` (same bank 35) is LVCMOS33 | `x_mixed.txt`: DRC BIVC-1, *Placer not run* |
| the 8 ports | bank 34: `led[0]`, `led[1]`; bank 35: the other six (`io_base.csv`) |
| `DRIVE 4`, `SLEW FAST`, `PULLTYPE PULLDOWN` | `io_props.csv` vs `io_base.csv` (default LED: 12 mA, SLOW) |
| `create_clock` period sweep, same design | `period_sweep.csv`: 8 ns +1.074, 5 ns -0.954, 4 ns -2.024, 3 ns -3.036, 2.5 ns -3.525 ns — **bitstream written every time** |
| pin `Z99` | `x_nopin.txt`: CRITICAL WARNING Common 17-69, then NSTD-1/UCIO-1, no bitstream |
| two ports on one pin | `x_dup.txt`: Vivado 12-1411, then NSTD-1/UCIO-1, no bitstream |
| `for` loop inside an `.xdc` | `x_for.txt`: Designutils 20-1307, command not supported |
| the same pins as Tcl loops, **sourced** | `io_loop.csv` identical to `io_base.csv` (`constraints/pins_loop.tcl`) |

Notes: slack at the tighter periods is the final routed value; Vivado works harder when timing fails, so the path settles near 6 ns instead of growing. Nothing here was run on a physical board.

## Run it
```bash
source <vivado install>/settings64.sh
make experiments
```
**Challenge:** change the LED drive and slew in `constraints/base.xdc`, rebuild, and confirm the change in `report_io`.
