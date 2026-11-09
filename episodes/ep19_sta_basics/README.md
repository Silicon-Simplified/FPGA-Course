# Episode 19 — Static timing analysis from first principles (companion code)

`rtl/sta_demo.v`: a 16-bit registered adder (`a_r + b_r -> s_r`) and a direct flip-flop pair (`sh1 -> sh2`). `scripts/sta.tcl` implements it once for the PYNQ-Z2 (`xc7z020clg400-1`, Vivado 2023.2, out-of-context) and reads the worst setup and hold path at 5, 3, 2.2 and 2 ns.

**Setup path** `a_r_reg[1] -> s_r_reg[13]`, 5 ns clock (`reports/setup_path.rpt`):

| | ns |
|---|---|
| arrival = source clock 0.973 + clk-to-Q 0.456 + routing 0.645 + 4 x CARRY4 1.069 | 3.143 |
| required = capture edge 5.000 + dest. clock 0.924 − uncertainty 0.035 + setup term 0.062 | 5.951 |
| slack = required − arrival | +2.808 |

Same path at 3.0 / 2.2 / 2.0 ns: +0.808 / +0.008 / −0.192, i.e. slack = period − 2.192 ns (about 456 MHz for this path alone).

**Hold path** `sh1 -> sh2` (`reports/hold_path.rpt`, fast corner): arrival 0.410 + 0.164 + 0.116 = 0.690; required 0.432 + 0.052 = 0.484; slack +0.207 ns — the same at every clock period. Setup is analysed at the slow corner, hold at the fast corner.
`reports/paths.csv` holds all the numbers. Nothing was run on a physical board.

## Run it
```bash
source <vivado install>/settings64.sh
make sta
```
**Challenge:** add a fifth adder stage to the path, predict the new slack at 5 ns, then check it.
