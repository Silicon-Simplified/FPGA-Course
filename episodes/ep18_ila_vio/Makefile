# make ila W=8 D=1024 TAG=w8_d1024  - build the design with an ILA (W probe bits, D samples); W=0 builds the baseline.   make vio - cost of a VIO core
W ?= 8
D ?= 1024
TAG ?= w$(W)_d$(D)
ila:
	vivado -mode batch -nojournal -nolog -source scripts/ila.tcl -tclargs $(W) $(D) $(TAG)
vio:
	mkdir -p build/vio_work && cd build/vio_work && vivado -mode batch -nojournal -nolog -source ../../scripts/vio.tcl -tclargs ../../reports
clean:
	rm -rf build .Xil
.PHONY: ila vio clean
