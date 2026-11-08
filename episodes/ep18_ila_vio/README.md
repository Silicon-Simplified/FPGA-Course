# Episode 18 — Debug on hardware: ILA and VIO (companion code)

`rtl/dbg_demo.v`: a 32-bit counter marked `mark_debug`, LEDs = `cnt[27:24]`. `scripts/ila.tcl` synthesizes it for the PYNQ-Z2 (`xc7z020clg400-1`), inserts an ILA with `create_debug_core` / `connect_debug_port` / `implement_debug_core`,
implements it, writes the bitstream and the probes file (`.ltx`). `scripts/vio.tcl` generates a VIO IP and reports its size. Vivado 2023.2.

| config | LUT | FF | BRAM tiles (of 140) | worst setup slack |
|---|---|---|---|---|
| no debug core | 2 | 34 | 0 | +5.325 ns |
| ILA 8 probes x 1024 | 1042 | 1809 | 0.5 | +2.566 ns |
| ILA 8 x 8192 | 1047 | 1847 | 2 | +2.095 ns |
| ILA 32 x 1024 | 1102 | 1931 | 1 | +1.593 ns |
| ILA 32 x 8192 | 1115 | 1969 | 7.5 | +2.337 ns |
| ILA 32 x 16384 | 1132 | 1983 | 15 | +1.333 ns |
| VIO, 4 inputs + 4 outputs | 146 | 306 | 0 | - |

The bitstream is 4,045,668 bytes in every case; `reports/probes_w8_d1024.ltx` shows the probe-name file. Capture window = depth x 8 ns at 125 MHz (1024 samples = 8.192 us).

**Honest note:** the cores were built in Vivado, but no board was programmed and nothing was captured. `.bit` files are not included (they are rebuilt by `make ila`).

## Run it
```bash
source <vivado install>/settings64.sh
make ila W=8 D=1024      # one ILA configuration  -> reports/ila_<tag>.csv
make vio
```
**Challenge:** 16 probes x 4096 samples: predict the block RAM count, then check.
