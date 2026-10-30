# Episode 1 — What is an FPGA? (companion code)

Proves the core idea of the episode: **any logic function of up to 6 inputs fits in one LUT**.

| File | What it is |
|---|---|
| `rtl/any_function.v` | `y = (a & b) \| (c ^ d)` — 4 inputs |
| `rtl/six_input_function.v` | a 6-input function that uses every input |
| `tb/tb_any_function.v` | exhaustive self-checking testbench |
| `scripts/synth.tcl` | Vivado non-project synthesis for Basys 3 (Artix-7) |
| `reports/` | real utilization reports from Vivado 2023.2 |

## Run it
```bash
# simulate (Vivado simulator)
xvlog rtl/any_function.v tb/tb_any_function.v && xelab tb_any_function -R

# synthesize and print LUT count
vivado -mode batch -source scripts/synth.tcl
```
Expected: `PASS: all 16 combinations correct`, and **1 LUT** for each design
(`LUT4` for the 4-input function, `LUT6` for the 6-input one).

**Challenge:** add a 7th input. How many LUTs now, and why?
