# Episode 41 — Capstone 1: a digital down-converter (companion code)

`rtl/nco.v` (32-bit phase accumulator + 4096-entry cos / −sin tables), `rtl/ddc_top.v` (mixer), `rtl/cic_decim.v` (3 integrators, ÷50, 3 combs, 33-bit wrap-around registers), `rtl/fir_decim.v` (31 taps, ÷4, one shared multiplier-accumulator). 12-bit input at 100 MHz → complex baseband (16-bit I and Q) at 500 kHz. The NCO is set to 10.7 MHz (`inc` = 459,561,501).
`tools/ddc_model.py`: generates the tables and FIR coefficients (`rtl/*.mem`), a **bit-exact integer model** of the whole chain, the test signals and the spectrum analysis; `tb/tb_ddc.v` runs the RTL in Verilator. `scripts/build.tcl`: out-of-context Vivado flow for the PYNQ-Z2's `xc7z020clg400-1` at a 10 ns clock.

| experiment | result (`reports/`) |
|---|---|
| bit-exact check (`sim_ddc.txt`) | RTL vs the Python model, 2047 output samples (I and Q): **0 mismatches** |
| two-tone test | wanted tone at fc + 20 kHz appears at **19.9 kHz** (bin width about 0.28 kHz); an interferer of the same amplitude at fc + 700 kHz leaves **−89.5 dBc** at its alias (+200 kHz); worst spur anywhere (outside ±3.3 kHz of the peak) **−69.0 dBc** |
| frequency response, single tones | measured vs ideal (CIC × quantized FIR): +10 kHz 0.00 / 0.00 dB, +50 kHz −0.03 / −0.03, +100 kHz −0.11 / −0.11, +150 kHz −0.46 / −0.46, +200 kHz −2.14 / −2.14, +300 kHz −15.94 / −15.94 dB. At +400 and +700 kHz the broadband measurement is limited by the output's noise floor (−66 / −69 dB measured, ideal −69 / −91) |
| planted bug (`CICW = 24`) | CIC registers 24 bits instead of 33: **4094 mismatches**, worst spur −2.8 dBc: the output is garbage |
| Vivado, out of context (`build_summary.csv`) | **1045 LUT, 1553 FF, 4 block RAM tiles, 4 DSP48**, setup slack **+2.849 ns** at 100 MHz (rough Fmax estimate about 140 MHz: the design meets 10 ns, so that number is not a proven limit) |

**Honest notes:** the input is a simulated two-tone signal; there is no ADC, no antenna and no real radio signal, and nothing was run on a physical board. The first version of the mixer computed the 12 × 16-bit product in a 16-bit expression context and silently lost the top bits (output almost zero); the comparison against the model caught it, and the products are now full-width wires. The model is bit-exact by construction for this RTL (same integer arithmetic), so the 0 mismatches show that the RTL implements the model, not that the model is the best possible design. The frequency response was only measured with 8 single tones. The spectrum uses a Hann window on 1983 output samples.

## Run it
```bash
make tables   # regenerate rtl/*.mem
make test     # Verilator simulations + model comparison + analysis (a few minutes)
make build    # Vivado, out of context
```
**Challenge:** move the oscillator to 10.9 MHz (change `INC` in the model and in the testbench), keep the wanted tone at fc + 20 kHz, and check that the result is still bit-exact.
