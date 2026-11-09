# Episode 20 — Clocks: MMCM, PLL and generated clocks (companion code)

`rtl/clk_demo.v`: one `MMCME2_BASE` turns the PYNQ-Z2's 125 MHz clock into 250 MHz and 62.5 MHz (VCO = 125 x 8 / 1 = 1000 MHz; outputs / 4 and / 16), each through a BUFG, with a counter in each domain.
`scripts/clk.tcl` implements it for `xc7z020clg400-1` (Vivado 2023.2). `scripts/wiz.tcl` generates the Clocking Wizard IP for the same job.

| result | value |
|---|---|
| Clocking Wizard (125 in; 250 + 62.5 out) | divider 1, multiplier 8, output dividers 4 and 16 — the same numbers; netlist: 1 MMCME2_ADV, 3 BUFG, 1 IBUF |
| clocks (only `sys_clk` is constrained) | derived by Vivado: `c0` 4.000 ns, `c1` 16.000 ns, `fb` 8.000 ns (`reports/clocks.csv`) |
| setup / hold slack | `c0` +1.467 / +0.252 ns; `c1` +13.558 / +0.252 ns |
| clock uncertainty | direct clock (Ep. 19) 0.035 ns; `c0` 0.063 ns; `c1` 0.076 ns = sqrt(TSJ^2 + DJ^2)/2 + PE with TSJ 0.071, DJ 0.104 / 0.135 |
| device | 4 MMCM, 4 PLL, 32 BUFG; the design uses 1 MMCM, 3 BUFG |
| VCO out of range (`CLKFBOUT_MULT_F = 4`, 500 MHz) | `reports/x_vco.txt`: DRC AVAL-46 critical warning at placement, then ERROR PDRC-34, "Router not run" |

Nothing was run on a physical board.

## Run it
```bash
source <vivado install>/settings64.sh
make clk
make wizard
```
**Challenge:** make 100 MHz and 200 MHz from the 125 MHz input, find a legal VCO frequency, then check it in Vivado.
