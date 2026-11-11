# Silicon Simplified: Xilinx FPGA Course

Companion code for the **Silicon Simplified** YouTube series, a complete, hands-on course on Xilinx / AMD FPGAs:
from "what is an FPGA?" to timing closure and Zynq SoCs.

Every number shown in the videos comes from a real run of the code in this repository
(Vivado simulator, Verilator lint, and AMD Vivado 2023.2 synthesis / implementation).

- **Board:** TUL **PYNQ-Z2** (Zynq-7020, part `xc7z020clg400-1`, 125 MHz PL clock). Episode 1 was recorded on the Basys 3 (Artix-7); the 7-series logic is identical, and every later episode targets the PYNQ-Z2.
- **Tools:** AMD Vivado 2023.2 (free edition), Verilator (optional, for lint)

## Episodes

| # | Episode | Code | Video |
|---|---|---|---|
| 1 | What is an FPGA? How it really works inside | [ep01](episodes/ep01_what_is_an_fpga) | [Watch](https://youtu.be/5TFQvzD636w) |
| 2 | Xilinx / AMD families explained, and how to choose your first board | [ep02](episodes/ep02_xilinx_families) | coming soon |
| 3 | Inside an FPGA slice: LUTs, carry chains, shift registers, distributed RAM | [ep03](episodes/ep03_seven_series_clb) | coming soon |
| 4 | Digital logic for FPGA designers: combinational vs sequential, delay, setup and hold | [ep04](episodes/ep04_digital_logic) | coming soon |
| 5 | Verilog basics: think in hardware | [ep05](episodes/ep05_verilog_basics) | coming soon |
| 6 | Blocking vs non-blocking assignments | [ep06](episodes/ep06_blocking_nonblocking) | coming soon |
| 7 | Counters, enables and resets done right | [ep07](episodes/ep07_counters_resets) | coming soon |
| 8 | Finite state machines | [ep08](episodes/ep08_state_machines) | coming soon |
| 9 | Testbenches that check themselves | [ep09](episodes/ep09_self_checking_tb) | coming soon |
| 10 | SystemVerilog for synthesis | [ep10](episodes/ep10_systemverilog) | coming soon |
| 11 | Parameters & generate | [ep11](episodes/ep11_parameters_generate) | coming soon |
| 12 | A tour of Vivado: project vs non-project mode | [ep12](episodes/ep12_vivado_tour) | coming soon |
| 13 | First hardware: a blinky, end to end on the PYNQ-Z2 | [ep13](episodes/ep13_first_blinky) | coming soon |
| 14 | XDC constraints from zero | [ep14](episodes/ep14_xdc_constraints) | coming soon |
| 15 | Reading synthesis results | [ep15](episodes/ep15_synthesis_results) | coming soon |
| 16 | Implementation deep dive | [ep16](episodes/ep16_implementation) | coming soon |
| 17 | Git-friendly Vivado: Tcl builds and CI | [ep17](episodes/ep17_git_ci) | coming soon |
| 18 | Debug on hardware: ILA and VIO | [ep18](episodes/ep18_ila_vio) | coming soon |
| 19 | Static timing analysis from first principles | [ep19](episodes/ep19_sta_basics) | coming soon |
| 20 | Clocks: MMCM, PLL and generated clocks | [ep20](episodes/ep20_clocks_mmcm) | coming soon |
| 21 | Reading timing reports like a pro | [ep21](episodes/ep21_timing_reports) | coming soon |
| 22 | Fixing timing: pipelining and retiming | [ep22](episodes/ep22_fixing_timing) | coming soon |
| 23 | I/O timing: input and output delays | [ep23](episodes/ep23_io_timing) | coming soon |
| 24 | Clock domain crossing | [ep24](episodes/ep24_cdc) | coming soon |
| 25 | Timing exceptions: use and abuse | [ep25](episodes/ep25_exceptions) | coming soon |
| 26 | Physical design: floorplanning and Pblocks | [ep26](episodes/ep26_floorplanning) | coming soon |
| 27 | Block RAM and distributed RAM | [ep27](episodes/ep27_block_ram) | coming soon |
| 28 | DSP48 inference | [ep28](episodes/ep28_dsp48) | coming soon |
| 29 | FIFOs: synchronous and asynchronous | [ep29](episodes/ep29_fifos) | coming soon |
| 30 | UART from scratch | [ep30](episodes/ep30_uart) | coming soon |
| 31 | SPI & I²C masters | [ep31](episodes/ep31_spi_i2c) | coming soon |
| 32 | VGA display controller | [ep32](episodes/ep32_vga) | coming soon |
| 33 | IP Integrator & AXI-Stream | [ep33](episodes/ep33_axis) | coming soon |
| 34 | Zynq architecture: PS + PL | [ep34](episodes/ep34_zynq) | coming soon |
| 35 | Custom AXI4-Lite IP + C driver | [ep35](episodes/ep35_axil) | coming soon |
| 36 | AXI DMA streaming | [ep36](episodes/ep36_dma) | coming soon |
| 37 | Interrupts PS↔PL | [ep37](episodes/ep37_irq) | coming soon |

More episodes are added as they are released.

## How to use this repository

Each episode folder is self-contained:

```
episodes/epXX_name/
  README.md      what the code shows and the results to expect
  rtl/           Verilog design files
  tb/            self-checking testbenches
  scripts/       Tcl and shell scripts (simulation, synthesis, implementation)
  reports/       the real Vivado / simulator results shown in the video
  constraints/   .xdc pin files (where a design goes on the board)
```

Typical commands (from inside an episode folder):

```bash
source <vivado install>/settings64.sh      # e.g. ~/Xilinx/Vivado/2023.2/settings64.sh
bash scripts/sim_all.sh                    # run the self-checking testbenches
vivado -mode batch -source scripts/<script>.tcl
```

Every episode README lists its exact commands, and ends with a challenge to try yourself.

## Pin constraints

Constraint files target the PYNQ-Z2. Pin names are copied from the official PYNQ-Z2 constraints (Xilinx/PYNQ, `boards/Pynq-Z2/base/vivado/constraints/base.xdc`); the 125 MHz clock pin (H16) comes from the board reference manual.
Vivado checks that they are legal for the package, but they have not been tested on a physical board, so always confirm against your board's reference manual.

## License

Code in this repository is released under the [MIT License](LICENSE). Video content is © Silicon Simplified.
