# Episode 34 — Zynq architecture: PS + PL (companion code)

`scripts/ps_bd.tcl`: builds the smallest Zynq design in IP Integrator, entirely from Tcl: just the `processing_system7` block with `M_AXI_GP0` and `S_AXI_HP0` enabled and two PL clocks (`FCLK_CLK0` 100 MHz, `FCLK_CLK1` 50 MHz). It validates the design, writes the interface list, implements it, writes the bitstream and exports the hardware platform (`.xsa`) that Vitis starts from.
PYNQ-Z2 part (`xc7z020clg400-1`), Vivado 2023.2.

| result (`reports/`) | value |
|---|---|
| block design (`ps_bd.tcl`, `ps_interfaces.txt`) | interfaces DDR, FIXED_IO, M_AXI_GP0, S_AXI_HP0 (+ HP0 FIFO control); clocks 100 MHz and 50 MHz |
| implementation (`build_summary.csv`) | OK; **bitstream 4,045,670 bytes**; **hardware platform .xsa 238,550 bytes** |
| PL usage (`utilization.rpt`) | **0 of 53,200 LUTs** used (the design has no logic); device has 106,400 FF, 140 BRAM tiles, 220 DSP |

**Honest notes:** the AXI port list (2 master GP, 2 slave GP, 4 slave HP, 1 ACP), the address windows (DDR from 0x0, GP0 at 0x4000_0000, GP1 at 0x8000_0000) and the boot sequence (boot ROM → FSBL → optional bitstream → application) shown in the video come from the Zynq-7000 technical reference manual, not from a measurement here. The memory (DDR) settings in this block design are Vivado's defaults, **not** the PYNQ-Z2 board preset (board files were not installed), so this platform is for study and is not expected to boot a real board. Nothing was run on a physical board. The `.xsa` and the bitstream are not included in this repository.

## Run it
```bash
source <vivado install>/settings64.sh
make ps
```
**Challenge:** enable `M_AXI_GP1` and the ACP (`S_AXI_ACP`) in the script, rebuild, and compare `ps_interfaces.txt`.
