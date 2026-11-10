# make sim    - loopback, tolerance sweep, break, and the 921600 case (Verilator; run from a folder whose path has NO spaces)
# make build  - the PYNQ-Z2 echo design (full flow incl. bitstream, about 3 minutes) -> reports/
sim:
	mkdir -p build && cd build && verilator --binary --timing -Wno-fatal -Wno-lint -Wno-style --top-module tb_uart ../rtl/uart.v ../tb/tb_uart.v > vl.log && ./obj_dir/Vtb_uart
	cd build && verilator --binary --timing -Wno-fatal -Wno-lint -Wno-style --top-module tb_hi -Mdir o2 ../rtl/uart.v ../tb/tb_hi.v > vl2.log && ./o2/Vtb_hi
build:
	vivado -mode batch -nojournal -nolog -source scripts/build.tcl
clean:
	rm -rf build .Xil clockInfo.txt
.PHONY: sim build clean
