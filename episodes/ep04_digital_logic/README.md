# Episode 4 — Digital logic for FPGA designers (companion code)

Every number in the video comes from these files: Vivado 2023.2 simulation (`xsim`) and implementation for the Basys 3
part (`xc7a35tcpg236-1`, speed grade -1, out-of-context synthesis + place + route). Testbenches are self-checking.

| Design | What it shows | Result |
|---|---|---|
| `rtl/fa_gates.v` / `rtl/fa_rtl.v` | the same full adder as gates vs as behaviour | **both = 2 × LUT3, identical INIT (`96` sum, `E8` carry)** |
| `rtl/comb_vs_seq.v` | `a & b` combinational vs registered | waveform: comb follows at once, register waits for the clock edge |
| `rtl/path_demo.v` | reg → add → xor → compare → reg | 10 ns: slack **+5.032 ns**, data path **4.686 ns** (logic 2.185 / route 2.501), 5 logic levels |
| `rtl/path_demo_piped.v` | same function with one pipeline register | 2 logic levels; slack at 4 ns **+1.037** vs +0.340 unpipelined |

## Run it
```bash
source <vivado install>/settings64.sh
bash scripts/sim_all.sh                               # testbenches + reports/wave.vcd
vivado -mode batch -source scripts/synth_adders.tcl   # -> reports/adders.csv
vivado -mode batch -source scripts/timing_demo.tcl    # -> reports/timing.csv, reports/*_path_10ns.rpt
```

## Timing in one line
`T_clk  >=  t_clock-to-Q  +  t_logic + t_routing  +  t_setup`   (Vivado also accounts for clock skew and uncertainty)
`slack = required time - arrival time`  (positive = met, negative = violated)

**Challenge:** in `timing_demo.tcl` find the 2.5 ns run of `path_demo` (negative slack), then add a pipeline register
to `path_demo.v` and watch the slack improve.
