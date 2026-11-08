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
