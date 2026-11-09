# make fail - implement the failing design at 125 MHz and write the reports used in the video (about 1.5 minutes)
fail:
	vivado -mode batch -nojournal -nolog -source scripts/fail.tcl
clean:
	rm -rf .Xil clockInfo.txt
.PHONY: fail clean
