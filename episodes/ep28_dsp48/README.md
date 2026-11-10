# Episode 28 — DSP48 inference (companion code)

`rtl/dsp_variants.v`: one 16 x 16 signed multiplier with 0–3 pipeline stages (`m0`..`m3`), a multiply-accumulate (`mac`), a pre-adder version (`preadd`) and a version with DSPs forbidden (`m3_lut`).
`scripts/gen_fir.py` generates the 8-tap low-pass FIR (`rtl/fir8.v`, transposed form; coefficients −236 0 4426 12194 12194 4426 0 −236, Q1.15); `rtl/fir8_df.v` is the direct form. Vivado 2023.2, PYNQ-Z2 part `xc7z020clg400-1`, out-of-context, ports timed against the clock with 0 ns delay.

| experiment (5 ns clock) | DSP | LUT / FF | register attributes | slack | implied period (derived: 5 − slack) |
|---|---|---|---|---|---|
| `m0` no registers | 1 | 0 / 0 | 0 / 0 / 0 / 0 | −0.822 | 5.822 ns |
| `m1` P register | 1 | 0 / 0 | PREG = 1 | +1.194 | 3.806 ns |
| `m2` M + P | 1 | 0 / 0 | MREG = PREG = 1 | +2.585 | 2.415 ns (≈ 414 MHz) |
| `m3` A + B + M + P | 1 | 0 / 0 | AREG = BREG = MREG = PREG = 1 | +2.585 | 2.415 ns (no further gain) |
| `mac` | 1 | 0 / 2 | all 1 | +1.642 | 3.358 ns (the accumulator loop) |
| `preadd` (a+d)*b | 1 | 0 / 0 | USE_DPORT = 1 | +2.585 | 2.415 ns |
| `m3_lut` (DSPs forbidden) | 0 | 294 / 96 | – | −4.100 | 9.100 ns |

| FIR at 250 MHz (4 ns) | DSP | LUT / FF | slack |
|---|---|---|---|
| transposed form (`fir8`) | 6 (two coefficients are zero) | 3 / 0 | +0.888 |
| direct form (`fir8_df`) | 9 | 8 / 16 | +0.221 |

`tb/tb_fir.v` + `scripts/check_fir.py` (`reports/fir_check.txt`): an impulse, two tones and noise, 598 samples compared with the numpy convolution: **maximum error 0**; DC gain 1.0000, gain at 0.45 × fs 0.0068 (−43 dB).
Notes: the timing numbers are port-to-register paths in an out-of-context run, so the implied periods are indicative (a real design adds routing and I/O). Run the simulation in a folder whose path has no spaces. Nothing was run on a physical board.

## Run it
```bash
source <vivado install>/settings64.sh
make variants
make fir
make sim
```
**Challenge:** change two zero coefficients to non-zero values, predict the DSP count, then check it.
