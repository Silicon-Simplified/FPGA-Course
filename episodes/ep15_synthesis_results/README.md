# Episode 15 — Reading synthesis results (companion code)

`rtl/zoo.v` holds ten small blocks. `scripts/zoo.tcl` synthesizes each one on its own (Vivado 2023.2, out-of-context, `xc7z020clg400-1`, the PYNQ-Z2's Zynq-7020) and writes `reports/zoo.csv`.

| block | what Vivado built |
|---|---|
| `add16` (registered a+b) | 16 LUT, 16 FF, 4 CARRY4 |
| `mux4_8` | 8 LUT |
| `rom32x8` (case statement) | 7 LUT |
| `ram1k_bram` (1024x8, registered read) | 1 RAMB18, 0 LUT |
| `ram1k_dist` (same, `ram_style="distributed"`) | 140 LUT (128 as RAM), 8 FF |
| `mult18_dsp` (18x18 registered) | 1 DSP, 0 LUT, 0 FF |
| `mult18_lut` (`use_dsp="no"`) | 342 LUT, 56 CARRY4, 36 FF |
| `shreg32` (32-deep, 1 bit, no reset) | 1 SRL, 2 FF |
| `latch_bug` (`if` without `else`) | 4 latches, Synth 8-327 |
| `trim_demo` | unused register removed (Synth 8-6014); the constant register vanishes with no warning; 8 of 17 flip-flops remain |

`reports/warnings.txt` has the two warnings that matter; Synth 8-7080 ("Parallel synthesis criteria is not met") appears in every run and is noise. Synthesis results only — nothing was run on a physical board.

## Run it
```bash
source <vivado install>/settings64.sh
make zoo
```
**Challenge:** write a 64-deep, 8-bit delay line, predict how many SRL LUTs it needs, then synthesize it and check.
