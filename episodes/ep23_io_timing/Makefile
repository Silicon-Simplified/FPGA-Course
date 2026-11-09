# make sim            - simulate the SPI reader against an ADC model (Verilator; run from a path WITHOUT spaces)
# make io             - the three flows: none / fabric / iob   (about 3 minutes) -> reports/
# make min25          - the challenge: minimum input delay 2.5 ns
sim:
	mkdir -p build/vsim && verilator --binary --timing -Wno-fatal -Wno-lint -Wno-style --top-module tb_spi_adc -Mdir build/vsim rtl/spi_adc.v tb/tb_spi_adc.v > build/vsim.log && ./build/vsim/Vtb_spi_adc
io:
	for m in none fabric iob; do vivado -mode batch -nojournal -nolog -source scripts/ioflow.tcl -tclargs $$m; done
min25:
	for m in fabric iob; do vivado -mode batch -nojournal -nolog -source scripts/ioflow.tcl -tclargs $$m 2.5; done
clean:
	rm -rf build .Xil clockInfo.txt
.PHONY: sim io min25 clean
