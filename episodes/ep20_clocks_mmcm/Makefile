# make clk - implement the MMCM design and dump clocks/timing (about 1.5 minutes) -> reports/
clk:
	vivado -mode batch -nojournal -nolog -source scripts/clk.tcl
wizard:
	mkdir -p build/wiz && cd build/wiz && vivado -mode batch -nojournal -nolog -source ../../scripts/wiz.tcl -tclargs ../../reports
clean:
	rm -rf build .Xil
.PHONY: clk wizard clean
