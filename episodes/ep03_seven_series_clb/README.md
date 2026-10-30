# Episode 3 — Inside a 7-series slice (companion code)

Every number in the video comes from these designs, run through **Vivado 2023.2** for the Basys 3 part (`xc7a35tcpg236-1`,
out-of-context synthesis + placement) and from Vivado's device model. All testbenches are self-checking.

| Design | What it shows | Vivado result |
|---|---|---|
| `rtl/dual_lut.v` | two 5-input functions, plain Verilog | 2 LUT5, 2 slice LUTs |
| `rtl/dual_lut_prim.v` | same two functions with the `LUT6_2` primitive | **1** slice LUT (O5 + O6) |
| `rtl/wide7.v` | 7-input function | 2 LUT6 + 1 MUXF7 |
| `rtl/wide8.v` | 8-input function | 4 LUT6 + 2 MUXF7 + 1 MUXF8 |
| `rtl/adder.v` (W=8 / 32) | `a + b` | 8 LUT2 + 2 CARRY4 / 32 LUT2 + 8 CARRY4 |
| `rtl/adder_co.v` (W=8) | the same with carry-out kept | 8 LUT2 + 3 CARRY4 |
| `rtl/srl_delay.v` (32 / 64 / 128) | delay line, no reset | 1 / 2 / 4 SRLC32E (+2 FFs) |
| `rtl/srl_delay_ff.v` | same with reset | 32 flip-flops, no SRL |
| `rtl/srl_var.v` | variable tap | 1 SRLC32E, any delay 1..32 |
| `rtl/dram64x8_sp.v` | 64x8 RAM, one address | 8 LUTs (RAM64X1S) |
| `rtl/dram64x8.v` | 64x8 RAM, separate read/write address | 12 LUTs (3 x RAM64M) |

## Run it
```bash
source <vivado install>/settings64.sh
bash scripts/sim_all.sh                                   # all testbenches (xsim)
vivado -mode batch -source scripts/synth_all.tcl          # -> reports/primitives.csv + per-design utilization
vivado -mode batch -source scripts/slice_count.tcl        # -> reports/slice_types.csv (SLICEL vs SLICEM)
```

**Challenge:** write an 8-bit adder and a 32-bit delay and find CARRY4 and SRLC32E in the utilization report.
**Question:** why does a reset on every bit stop Vivado from using an SRL?
