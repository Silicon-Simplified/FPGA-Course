# make zoo - synthesize every block of rtl/zoo.v on its own (about 2 minutes) -> reports/zoo.csv
zoo:
	vivado -mode batch -nojournal -log reports/zoo.log -source scripts/zoo.tcl
clean:
	rm -rf .Xil
.PHONY: zoo clean
