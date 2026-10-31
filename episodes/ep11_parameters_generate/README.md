# Episode 11 — Parameters & generate (companion code)

Every claim in the video is backed by a run: the Vivado simulator (self-checking testbenches) and Vivado 2023.2 synthesis for the PYNQ-Z2 part (`xc7z020clg400-1`, out-of-context).

| Design | What it shows | Result |
|---|---|---|
| `rtl/cnt_n.v` | one counter, width = parameter `W` | W = 4 / 8 / 16 / 32 / 64 → flip-flops 4 / 8 / 16 / 32 / 64; LUTs 4 / 9 / 1 / 1 / 1; **CARRY4** 0 / 0 / 4 / 8 / 16; logic levels 1 / 2 / 4 / 8 / 16 |
| `tb/tb_widths.sv` | generate loop in the testbench: same counter at 11 widths | every width (2…12 bits) wraps exactly at 2^W over 9000 clocks (2250 wraps at 2 bits … 2 at 12 bits) |
| `rtl/led_bar.v` | generate-for thermometer LED bar | N = 8 / 16 / 32 → **7 / 15 / 31 LUTs**, 1 level (the top LED is a wire); exhaustive test passes |
| `rtl/rca_gen.v` vs `rtl/add_plus.v` | ripple adder built from full-adder instances vs the `+` operator | N = 32: generate version **75 LUTs, 0 CARRY4, 13 levels** · `+` **32 LUTs, 9 CARRY4, 10 levels**. Both exhaustively correct (65,536 pairs) |
| `rtl/opt_pipe.sv` | generate-if option + elaboration error | PIPELINE = 0 → 16 LUT, 0 FF · PIPELINE = 1 → 16 LUT, **16 FF**. W = 1 → `ERROR: [Synth 8-6058] Synth Error: opt_pipe: W must be at least 2, got 1` |

## Run it
```bash
source <vivado install>/settings64.sh
bash scripts/sim_all.sh                                   # testbenches
vivado -mode batch -source scripts/synth_all.tcl          # -> reports/synth_summary.csv
```
**Challenge:** synthesize `cnt_n` at W = 128. Predict the CARRY4 count and the logic levels, then check in Vivado.
