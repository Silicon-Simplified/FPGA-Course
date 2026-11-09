# Episode 25 — Timing exceptions: use and abuse (companion code)

`rtl/exc_demo.v` has four paths you might be tempted to put an exception on (PYNQ-Z2, `xc7z020clg400-1`, Vivado 2023.2): **P1** a quasi-static configuration word feeding a long adder; **P2** a datapath that only updates every 2nd clock; **X** a 250 MHz → 62.5 MHz counter read without a synchronizer; **G** a Gray-coded pointer into a 2-FF synchronizer.
`scripts/exc.tcl` implements it once with **no exceptions** and then applies them one after another (timing analysis only); every step is a row of `reports/exceptions.csv`.

| step | what it shows |
|---|---|
| 0 no exceptions | WNS −0.638 ns, TNS −9.802, 33 of 1524 endpoints fail; P1 −0.487, P2 −0.442, X +0.905, G +1.203 |
| 1 `set_false_path -from p1_cfg_reg*` | the P1 path is no longer reported, but WNS is unchanged (−0.638): the other words feeding the adder still fail |
| 2a `set_multicycle_path 2 -setup` | P2 −0.442 → **+7.558**, TNS −7.066, 22 fail, but worst **hold −7.337** |
| 2b + `set_multicycle_path 1 -hold` | worst hold back to +0.118 (P2 hold +0.699) |
| 3 `set_max_delay -datapath_only` on G | 4.0 ns: +1.750; 1.0 ns: **−1.250** (WNS −1.250, 30 fail) — a bounded check |
| 4 `set_clock_groups -asynchronous` (c0 / c1 are really related) | X and G are no longer timed (even with the max_delay: the clock group wins); endpoints 1524 → 1508 |
| 5 ABUSE `set_false_path -from sys_clk -to sys_clk` | **WNS +1.193, 0 failing**, but only **24** of 1524 endpoints still timed |

Notes: `report_exceptions` (`reports/report_exceptions.rpt`) lists every exception with a status; for the multicycle exceptions it said "Invalid endpoint" although their effect was visible (the `-to` objects were cells; use the `D` pins to be clean), and "Non-existent path" for the c1 → c0 direction of the clock groups.
`reset_timing` removes the clocks as well, so the script never uses it. A later `set_max_delay` on the same `-from/-to` replaces the earlier one. Nothing was run on a physical board.

## Run it
```bash
source <vivado install>/settings64.sh
make exceptions
```
**Challenge:** apply the multicycle exception to the wrong source register and see whether any report warns you.
