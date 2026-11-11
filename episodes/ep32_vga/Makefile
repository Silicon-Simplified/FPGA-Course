# VGA pattern generator - Episode 32. Needs Vivado 2023.2 on PATH (source settings64.sh) for `make build`, Verilator 5 for `make sim`.
.PHONY: sim build clean
sim:
	verilator --binary --timing -Wno-fatal --top-module tb_vga rtl/vga_timing.v rtl/bounce_logo.v rtl/vga_core.v tb/tb_vga.v && ./obj_dir/Vtb_vga
build:
	vivado -mode batch -source scripts/build.tcl
clean:
	rm -rf obj_dir *.jou *.log *.pb build frame_*.ppm
