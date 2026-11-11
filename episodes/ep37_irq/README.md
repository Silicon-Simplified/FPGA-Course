# Episode 37 — Interrupts between the PL and the PS (companion code)

`rtl/axil_irq.v`: a 4-button interrupt controller with an AXI4-Lite slave: synchronizer → debounce → press event → pending register (write-1-to-clear) → enable mask → level interrupt `irq`. `tb/tb_irq.v`: an AXI4-Lite master and a noisy-button model (`MUT=0` correct; `MUT=1` no debounce; `MUT=2` an acknowledge clears every bit). `scripts/build.tcl`: PS (IRQ_F2P enabled) + controller in IP Integrator, `irq` → `IRQ_F2P`, buttons on the PYNQ-Z2 pins, implementation, bitstream, `.xsa`. `sw/irq.h`: driver and interrupt service routine; `sw/test_irq.c`: tests them on the PC against a model; `sw/hello_irq.c`: the bare-metal example with the GIC set-up.
PYNQ-Z2 part (`xc7z020clg400-1`), Vivado 2023.2.

| register | address | |
|---|---|---|
| RAW | 0x00 | debounced button state, read-only |
| PENDING | 0x04 | pressed and not yet handled; write 1 to clear |
| ENABLE | 0x08 | interrupt mask |
| COUNT | 0x0C | press events since reset, read-only |
| ID | 0x10 | 0x49525101, read-only |

| experiment | result (`reports/`) |
|---|---|
| testbench (`sim_irq.txt`, debounce 16 clocks in simulation) | MUT=0: **22 checks, 0 errors**: one press with 3 bounces → 1 event; irq is a level (still high after 50 clocks); write-1-to-clear; masked press sets pending but not irq; two pending buttons, acknowledging one leaves the other; **20 noisy presses → exactly 20 events**; press to interrupt **19 clocks** (16 debounce + 2 synchronizer + 1). MUT=1 (no debounce): **182 events** for 20 presses. MUT=2: the other button's event is lost (2 check errors) |
| real debounce | 1,000,000 clocks = 10 ms at 100 MHz (parameter `DEB`) |
| block design (`address_map.txt`, `build_summary.csv`) | registers at **0x40000000** (4 KB); `irq` connected to `IRQ_F2P`; implementation OK; **447 LUT, 638 FF**; setup slack **+3.352 ns**; bitstream written; `.xsa` 267,806 bytes |
| ISR on the PC (`driver_test.txt`) | model of the peripheral + a level interrupt controller; a press arrives while the ISR runs: correct ISR: **called 2 times, 3 of 3 presses**; never acknowledges: **1000 calls (storm, stopped at the cap)**; acknowledges all bits: **2 of 3** presses |
| ARM compile (`arm_size.txt`) | `hello_irq.c` for Cortex-A9: 553 bytes of code (object file only) |

**Honest notes:** the ISR never ran on the processor (the Vitis IDE is not installed here), and nothing was run on a physical board. The GIC / exception set-up calls in `sw/hello_irq.c` (`XScuGic_*`, `Xil_Exception*`) are declared by hand from memory and were **not** compiled against the real BSP headers. The interrupt controller in `sw/test_irq.c` is my own simple model. The interrupt ID 61 for `IRQ_F2P[0]` comes from the Zynq-7000 reference manual. The memory (DDR) settings in the block design are Vivado's defaults, not the PYNQ-Z2 preset. The `.xsa` and bitstream are not included. Run the simulations in a folder whose path has no spaces.

## Run it
```bash
source <vivado install>/settings64.sh
make sim      # three variants of the testbench
make driver   # ISR test on the PC
make arm      # cross-compile for the ARM core
make build    # Vivado block design -> bitstream -> .xsa
```
**Challenge:** add a per-button edge-select register (press or release), extend the testbench, and update the ISR.
