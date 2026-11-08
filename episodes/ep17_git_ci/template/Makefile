# make lint | test | sim | bit | clean         (VIVADO=vivado by default)
VIVADO ?= vivado
TOP    ?= blinky
PART   ?= xc7z020clg400-1
lint:
	verilator --lint-only -Wall -Wno-DECLFILENAME -Wno-UNUSEDSIGNAL rtl/*.v --top-module $(TOP)
# open-source simulation (what CI runs)
test:
	mkdir -p build/vsim
	verilator --binary --timing -Wno-fatal -Wno-lint -Wno-style --top-module tb_blinky -Mdir build/vsim rtl/*.v tb/*.v > build/vsim.log
	./build/vsim/Vtb_blinky | tee build/test_output.txt
	grep -q PASS build/test_output.txt
# Vivado simulator
sim:
	bash scripts/sim.sh
bit:
	$(VIVADO) -mode batch -nojournal -nolog -source scripts/build.tcl -tclargs $(TOP) $(PART)
clean:
	rm -rf build .Xil .sim
.PHONY: lint test sim bit clean
