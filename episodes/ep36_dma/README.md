# Episode 36 — AXI DMA streaming and the cache (companion code)

`rtl/axis_avg4.v`: a streaming accelerator, a 4-sample moving average on signed 32-bit samples (one register stage, history cleared at TLAST). `tb/tb_avg4.v`: source → accelerator → sink with packets of 64 words and an independent model, in four traffic patterns plus two planted bugs. `scripts/build.tcl`: PS + AXI DMA (simple mode) + accelerator in IP Integrator, implementation, bitstream, `.xsa`. `sw/dma.h`: a register-level driver for the AXI DMA; `sw/test_dma.c`: tests it on the PC against a model of the DMA registers, DDR and a data cache; `sw/hello_dma.c`: the bare-metal example.
PYNQ-Z2 part (`xc7z020clg400-1`), Vivado 2023.2.

| experiment | result (`reports/`) |
|---|---|
| accelerator, 4096 samples × 4 traffic patterns (`sim_avg4.txt`) | all values correct, all TLAST correct; always/always: **4096 samples in 4096 clocks**; 50%/50%: 11,034; slow sink: 16,531; slow source: 15,710 clocks |
| planted bugs | history kept across packets: **189 wrong** (3 words × 63 packets); no hold (tready always 1): **2010 of 4096** samples arrive |
| block design (`address_map.txt`, `build_summary.csv`) | DMA registers at **0x40400000** (64 KB), DDR window 0x0 – 0x1FFFFFFF via HP0; implementation OK; **1848 LUT, 2531 FF, 2 block RAM tiles, 0 DSP**; setup slack **+2.535 ns** (100 MHz); bitstream written; `.xsa` 326,409 bytes |
| driver on the PC (`driver_test.txt`) | model of registers + accelerator + DDR + data cache, 256 samples: flush + invalidate: **0 wrong**; no flush: **251 wrong**; no invalidate: **256 wrong** |
| ARM compile (`arm_size.txt`) | `hello_dma.c` for Cortex-A9: 625 bytes of code, 2048 bytes of buffers (object file only) |

**Honest notes:** the DMA IP itself was not simulated, so the DMA behaviour in `sw/test_dma.c` is **my own model**, as is the cache (a simple word-granular write-back cache); real cache lines, write buffers and the L2 cache behave in more detail. The DMA register offsets and bits (`sw/dma.h`) come from the AXI DMA product guide (PG021), not from a measurement. The Vitis IDE is not installed here, so the software was compiled for the ARM core but never linked or run on the processor. Nothing was run on a physical board. The memory (DDR) settings in the block design are Vivado's defaults, not the PYNQ-Z2 preset. The `.xsa` and the bitstream are not included. Run the simulation in a folder whose path has no spaces.

## Run it
```bash
source <vivado install>/settings64.sh
make sim      # accelerator testbench
make driver   # driver + cache model test on the PC
make arm      # cross-compile for the ARM core
make build    # Vivado block design -> bitstream -> .xsa
```
**Challenge:** change the accelerator to an 8-sample average, and update the testbench model and the driver test.
