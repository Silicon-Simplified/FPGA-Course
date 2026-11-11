# Episode 32 — A VGA display controller (companion code)

`rtl/vga_timing.v`: 640×480 timing (800 clocks × 525 lines, active-low syncs). `rtl/bounce_logo.v`: a 64×48 box that moves (3, 2) pixels once per frame and bounces off the walls, changing colour. `rtl/vga_core.v`: the pixel pipeline (colour and sync registered together, black in blanking). `rtl/vga_top.v`: PYNQ-Z2 top level with an MMCM making the 25 MHz pixel clock.
PYNQ-Z2 (`xc7z020clg400-1`, 125 MHz), Vivado 2023.2.

| experiment | result (`reports/`) |
|---|---|
| timing at the output pins (`tb/tb_vga.v`, `sim_vga.txt`) | line **800 clocks**, hsync low 96; frame **420,000 clocks = 525 lines**, vsync low 2 lines; **307,200** visible pixels per frame; 0 bad lines/frames |
| pixel clock 25 MHz | line 31,250 Hz, frame **59.52 Hz** (the standard is 25.175 MHz / 59.94 Hz) |
| blanking | 0 non-black clocks outside the picture; mutation without blanking: **67,567,201** non-black clocks |
| bouncing box (`logo_path.csv`, `frame_a.png`, `frame_b.png`) | 600 frames: **5 bounces** (frames 158, 185, 350, 401, 542), 0 positions out of bounds; the PNGs are frames 2 and 300 of the simulated pixel stream |
| FPGA build (`build_summary.csv`) | **120 LUT, 62 FF, 19 IOBs, setup slack +32.568 ns** (25 MHz pixel clock), bitstream written |

**Honest notes:** nothing was run on a physical board, and no monitor or VGA adapter was connected. The PYNQ-Z2 has an HDMI connector but no VGA connector: the 4+4+4-bit colour and the two syncs are routed to the Pmod headers (R, G on Pmod A; B, hsync, vsync on Pmod B) for a resistor-ladder VGA adapter you would have to build. 25 MHz is slightly below the standard 25.175 MHz. Run the simulation in a folder whose path has no spaces.

## Run it
```bash
source <vivado install>/settings64.sh
make sim
make build
```
**Challenge:** make the box leave a trail, or add a second box that bounces at a different speed.
