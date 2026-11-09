# Episode 21 — Reading timing reports like a pro (companion code)

`rtl/fail_demo.v` sums 24 32-bit words in one clock cycle: intentionally too slow for the PYNQ-Z2's 125 MHz (8 ns) clock. `scripts/fail.tcl` implements it (Vivado 2023.2, out-of-context, `xc7z020clg400-1`) and writes the reports read in the video.

| report | what it shows |
|---|---|
| `timing_summary.rpt` | WNS -2.112 ns, TNS -44.954 ns over 32 failing endpoints of 805; hold WHS +0.110 ns, THS 0 (0 failing); pulse width WPWS +3.500 ns |
| `failing_endpoints.csv` | the 32 failing endpoints (all `sum_reg` bits), -2.112 … -0.133 ns; their slacks add up to exactly the TNS |
| `worst_setup.rpt` | 10.090 ns = 4.902 logic (48.6%) + 5.188 routing (51.4%); 15 logic levels (10 CARRY4, 3 LUT3, 1 LUT4, 1 LUT5) |
| `design_analysis.rpt` | logic-level distribution: 767 endpoints with 0 levels, the failures in a tail of 10–15 levels |
| `check_timing.rpt` | no_clock 0, constant_clock 0, unconstrained_internal_endpoints 0 — but `no_input_delay` 1 and `no_output_delay` 1 (ports `din` / `dout`) |

**Note (corrected in Episode 22):** in this script `create_clock` runs *after* `synth_design`, so synthesis did not know the 8 ns target. Episode 22's script reads the clock *before* synthesis; the same design then gives different numbers (WNS -1.359 ns). The way to read the reports is the same either way.
Nothing was run on a physical board.

## Run it
```bash
source <vivado install>/settings64.sh
make fail
```
**Challenge:** change the clock to 10 ns, re-run, and predict how many endpoints still fail before you look.
