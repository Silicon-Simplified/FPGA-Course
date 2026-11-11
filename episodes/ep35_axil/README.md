# Episode 35 — A custom AXI4-Lite peripheral and a C driver (companion code)

`rtl/axil_pwm.v`: a 4-channel PWM controller with an AXI4-Lite slave (AW and W accepted independently, in either order; byte strobes; read-only registers). `tb/tb_axil.v`: an AXI4-Lite master model (`MUT=0` correct; `MUT=1` ignores byte strobes; `MUT=2` uses the live address). `scripts/build.tcl`: PS + `axil_pwm` in IP Integrator, connection automation, implementation, bitstream, `.xsa`. `sw/pwm.h`, `sw/hello_pwm.c`: the bare-metal driver and hello world; `sw/test_driver.c`: the driver tested on the PC against a register-file model.
PYNQ-Z2 part (`xc7z020clg400-1`), Vivado 2023.2.

| register | address | |
|---|---|---|
| CTRL | 0x00 | bit 0 = enable |
| PERIOD | 0x04 | clocks per PWM period (reset 1000) |
| DUTY0 … DUTY3 | 0x08 … 0x14 | high time in clocks |
| COUNT | 0x18 | read-only period counter |
| ID | 0x1C | read-only, 0x50574D01 |

| experiment | result (`reports/`) |
|---|---|
| testbench (`sim_axil.txt`) | MUT=0: **93 checks, 0 errors** (reset values, read-back of 6 registers × 3 write orderings, byte strobes, read-only registers, PWM); PWM high clocks over 10 periods of 1000: **0 / 2500 / 5000 / 10000** for duty 0 / 250 / 500 / 1000; write 3 clocks, read 3 clocks. MUT=1 (ignore strobes): **2 errors**. MUT=2 (live address): **23 errors**, PWM never enabled |
| block design (`address_map.txt`, `build_summary.csv`) | peripheral at **0x40000000**, 4 KB (assigned by Vivado); implementation OK; **512 LUT, 742 FF** for the whole system incl. interconnect; setup slack **+3.393 ns** (100 MHz); bitstream written; `.xsa` 268,452 bytes |
| driver (`driver_test.txt`, `arm_size.txt`) | PC test: **10 checks, 0 errors**; `hello_pwm.c` cross-compiled with `arm-none-eabi-gcc -mcpu=cortex-a9`: **385 bytes** of code (object file only) |

**Honest notes:** the Vitis IDE is not installed here, so there is no Vitis project: the software was compiled for the ARM core but never linked, never run on the processor. Nothing was run on a physical board. The memory (DDR) settings in the block design are Vivado's defaults, not the PYNQ-Z2 preset. The `.xsa` and the bitstream are not included. Run the simulations in a folder whose path has no spaces.

## Run it
```bash
source <vivado install>/settings64.sh
make sim      # three variants of the testbench
make driver   # driver test on the PC
make arm      # cross-compile for the ARM core
make build    # Vivado block design -> bitstream -> .xsa
```
**Challenge:** add a register that inverts selected channels, extend the testbench, and add a driver call.
