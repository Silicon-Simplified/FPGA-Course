# Episode 33 — IP Integrator and AXI-Stream (companion code)

`rtl/axis_add.v`: a one-register AXI-Stream stage (out = in + K). `HOLD = 1` is the correct stage (ready when the output register is empty or being emptied); `HOLD = 0` is the planted bug (tready always 1).
`tb/tb_axis.v`: source → stage → sink under four traffic patterns, with a data checker and an AXI-Stream protocol monitor (valid, data and last must not change while valid && !ready).
`scripts/bd.tcl`: builds a block design in IP Integrator from Tcl: `axis_add` as a module reference + the AXI4-Stream Data FIFO (depth 512), external S_AXIS / M_AXIS ports, validates it, exports it to `reports/axis_pipe_bd.tcl`, and synthesizes it out of context.
PYNQ-Z2 part (`xc7z020clg400-1`), Vivado 2023.2.

| experiment | result (`reports/`) |
|---|---|
| 4 traffic patterns × 4096 words (`sim_axis.txt`) | all words correct, in order, TLAST on every 16th, **0 protocol violations**; A (always/always): **4096 words in 4096 clocks**; B (50%/50%): 11,034; C (slow sink, 25%): 16,531; D (slow source, 25%): 15,710 clocks |
| planted bug (tready always 1) | A and D: **0 errors (invisible)**; B: **2010 of 4096** words arrive, 2010 errors, 2086 violations; C: 1015 words, 1014 errors, 3081 violations |
| block design (`build_summary.csv`, `utilization.rpt`) | 2 cells; validates cleanly (the first attempt had critical warning BD 41-237: external port TDATA_NUM_BYTES 1 vs 4, fixed in the script); synthesis: **53 LUT, 87 FF, 0.5 block RAM tile** |

**Honest notes:** simulation and synthesis only. The design was not implemented, no bitstream was written, nothing ran on a board, and there is no processor (PS) or AXI-Lite in this design yet. The `wns_ns` value in `build_summary.csv` is a synthesis-only estimate without placement. Run the simulation in a folder whose path has no spaces.

## Run it
```bash
source <vivado install>/settings64.sh
make sim
make bd
```
**Challenge:** make the stage add a different constant to every word, then rerun the four patterns and the planted-bug test.
