# Episode 13 — First hardware: a blinky, end to end, on the PYNQ-Z2 (companion code)

A four-LED counter that steps once per second (switches SW1:SW0 pick 1, 2, 4 or 8 steps per second; BTN0 resets), taken from Verilog to a bitstream for the PYNQ-Z2 (`xc7z020clg400-1`, 125 MHz clock).
The design uses a clock enable (a tick every `CLK_HZ >> sw` cycles), not a divided clock — see Episode 7.

**Honest note:** this was simulated and built in Vivado 2023.2, but **never run on a physical board**. The pins come from the official PYNQ-Z2 constraints (clock H16 from the board manual) and Vivado accepts them for the package.
`scripts/prog.tcl` has never been run against hardware; check your board's manual for the JTAG boot mode.

| result | value |
|---|---|
| simulation (CLK_HZ = 64) | steps every 64 / 32 / 16 / 8 clocks for sw = 0..3, BTN reset OK — PASS |
| LUTs / flip-flops / pins | 42 / 37 / 8 |
| worst setup / hold slack | +1.074 ns / +0.053 ns |
| bitstream | 4,045,666 bytes |
| stage times (this machine) | synth 26.6 s, opt 4.9 s, place 1.5 s, route 20.2 s, bitstream 19.4 s |

Layout: `rtl/blinky.v`, `tb/tb_blinky.v`, `constraints/pynq_z2_blinky.xdc`, `scripts/` (`build.tcl`, `prog.tcl`, `sim.sh`, `errors.sh`), `reports/` (everything the video quotes, including the three error experiments `err1-3.txt`).

## Run it
```bash
source <vivado install>/settings64.sh
make sim     # self-checking testbench
make bit     # full flow -> out/blinky.bit and reports/
make prog    # program the board (untested on hardware)
```
**Challenge:** make the LEDs count down, rebuild, and compare the slack.
