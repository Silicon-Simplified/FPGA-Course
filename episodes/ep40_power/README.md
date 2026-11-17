# Episode 40 — Power analysis and optimisation (companion code)

Vivado's `report_power` on small designs for the PYNQ-Z2's `xc7z020clg400-1`: each variant is synthesized out of context, placed and routed, then analysed. Where the table says "simulated activity", a post-implementation functional simulation of the routed netlist with random data (`tb/tb_power.v`, 2000 clocks) records the switching activity (SAIF), which is read back into the power analysis. `scripts/run.tcl` runs everything and writes `reports/results.csv`.

**These are estimates from Vivado's power model, not measurements.** Nothing was compared with a power meter. The "High" confidence in the CSV rates the quality of the activity input, not the accuracy of the result.

| experiment | variant | total (W) | dynamic (W) | clocks / logic / signals (W) |
|---|---|---|---|---|
| 1 clock frequency (`pw.v`: 4096 accumulators, default vectorless activity) | 50 MHz | 0.144 | 0.040 | 0.016 / 0.019 / 0.005 |
| | 100 MHz | 0.185 | 0.081 | 0.032 / 0.039 / 0.010 |
| | 200 MHz | 0.267 | 0.162 | 0.063 / 0.078 / 0.021 |
| 2 enable gating (random data, 100 MHz) | free-running (any duty) | 0.215 | 0.111 | 0.032 / 0.069 / 0.011 |
| | flip-flop clock enable, duty 100% | 0.215 | 0.111 | 0.032 / 0.069 / 0.011 |
| | flip-flop clock enable, **duty 10%** | 0.146 | **0.043** (−61%) | 0.009 / 0.032 / <0.001 |
| | BUFGCE clock gate, duty 100% | 0.205 | 0.101 | 0.021 / 0.069 / 0.011 |
| | BUFGCE clock gate, **duty 10%** | 0.158 | **0.055** (−50%) | 0.021 / 0.033 / 0.001 |
| 3 32 multipliers 16×16 (`mul.v`) | DSP48 (32 DSP48, 0 LUT) | 0.141 | **0.038** | DSP 0.037 |
| | LUTs (8441 LUT, 0 DSP48) | 0.403 | **0.296** (7.8×) | 0.017 / 0.144 / 0.135 |
| 4 delay line 64 × 32 (`dly.v`) | SRL (no reset) | 0.105 | **0.002** | |
| | flip-flop chain | 0.137 | **0.034** (17×) | 0.020 / 0.002 / 0.012 |
| | block RAM | 0.106 | **0.003** | BRAM 0.003 |

Static power was 0.103 – 0.107 W in every experiment.

**Honest notes:** (1) one result is unexplained: with the BUFGCE the estimate gives the clock tree 0.021 W at both 100% and 10% enable duty, so it credits the flip-flop clock enable but not the clock gate in the clock tree. I cannot tell whether that is real or an artefact of the model, so do **not** conclude that clock enables beat clock gating. (2) The switching activity comes from 2000 clocks of random data; real data would differ. (3) `n/a` in the CSV means Vivado listed no value for that component and `<0.001` means below its reporting resolution. (4) Experiment 1 uses Vivado's default (vectorless) activity, the others simulated activity. (5) My first LUT-multiplier variant was silently mapped to DSP48 slices by the tool; the fix is the `use_dsp = "no"` attribute on the module, and `results.csv` shows the LUT count (8441) and DSP48 count (0) so you can check. (6) Nothing was run on a physical board.

## Run it
```bash
source <vivado install>/settings64.sh
make run      # about 35 minutes
```
**Challenge:** replace the random enable by a regular 1-in-10 pattern, regenerate the activity, and compare the estimates.
