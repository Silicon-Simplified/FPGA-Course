# make cdc      - report_cdc on the bad and the good design (about 4 minutes) -> reports/cdc_*.rpt
# make sim      - bus-skew experiment and the async FIFO test (Verilator; run from a folder whose path has NO spaces)
cdc:
	for t in cdc_bad cdc_good; do vivado -mode batch -nojournal -nolog -source scripts/cdc.tcl -tclargs $$t; done
sim:
	mkdir -p build && for t in tb_bus_skew tb_async_fifo; do verilator --binary --timing -Wno-fatal -Wno-lint -Wno-style --top-module $$t -Mdir build/$$t rtl/cdc_lib.v tb/$$t.v > build/$$t.log && ./build/$$t/V$$t | grep -a "SKEW_RESULT\|FIFO_"; done
clean:
	rm -rf build .Xil clockInfo.txt
.PHONY: cdc sim clean
