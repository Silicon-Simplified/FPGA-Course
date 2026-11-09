# Episode 24 — Clock domain crossing (companion code)

`rtl/cdc_lib.v` is a small CDC library: `sync2` (2-FF synchronizer with `ASYNC_REG`), `pulse_sync` (toggle synchronizer), `bin2gray` / `gray2bin`, and `async_fifo` (Gray pointers).
`rtl/cdc_bad.v` and `rtl/cdc_good.v` cross between a 250 MHz and a 62.5 MHz clock (one MMCM, declared asynchronous with `set_clock_groups -asynchronous`) on the PYNQ-Z2 (`xc7z020clg400-1`, Vivado 2023.2).

| experiment | result |
|---|---|
| `report_cdc` on `cdc_bad` (a 1-bit signal through one flip-flop; an 8-bit bus with nothing) | **CDC-1 Critical** "1-bit unknown CDC circuitry", **CDC-4 Critical** "Multi-bit unknown CDC circuitry" (`reports/cdc_details_cdc_bad.rpt`) |
| `report_cdc` on `cdc_good` (2-FF, Gray bus, pulse sync, async FIFO) | 20 endpoints, all Safe: Info **CDC-3** "1-bit synchronized with ASYNC_REG property" |
| the same without `ASYNC_REG` | the same 20 endpoints become **CDC-2 Warning** "missing ASYNC_REG property" |
| `tb/tb_bus_skew.v`: 8-bit counter, 0.3–2.75 ns bit skew, sampled from an unrelated clock, 20,000 samples | binary: **1455** corrupted (7.3%); Gray code: **0** |
| `tb/tb_async_fifo.v`: depth 16, write 5 ns, read 13 ns, 3000 words | in order, none lost, none duplicated; FIFO full seen 5846 times |

Honest notes: `report_cdc` checks the synchronizers; it cannot prove the FIFO's pointer protocol (the simulation covers that). With the Gray encoding removed the FIFO test fails (timeout). The metastability picture in the video is an illustration, not a measurement.
Nothing was run on a physical board.

## Run it
```bash
source <vivado install>/settings64.sh
make cdc
make sim       # in a folder whose path has no spaces
```
**Challenge:** build a handshake synchronizer (request / acknowledge) for an 8-bit value and run `report_cdc` on it.
