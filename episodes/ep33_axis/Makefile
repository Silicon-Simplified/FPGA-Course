# AXI-Stream + IP Integrator - Episode 33. Verilator 5 for `make sim`; Vivado 2023.2 on PATH for `make bd`.
.PHONY: sim bd clean
sim:
	verilator --binary --timing -Wno-fatal --top-module tb_axis rtl/axis_add.v tb/tb_axis.v && ./obj_dir/Vtb_axis
bd:
	vivado -mode batch -source scripts/bd.tcl
clean:
	rm -rf obj_dir *.jou *.log build .Xil
