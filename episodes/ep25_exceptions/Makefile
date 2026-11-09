# make exceptions - implement exc_demo once with no exceptions, then apply them one by one and record the effect (about 3 minutes) -> reports/exceptions.csv, report_exceptions.rpt
exceptions:
	vivado -mode batch -nojournal -nolog -source scripts/exc.tcl
clean:
	rm -rf .Xil clockInfo.txt
.PHONY: exceptions clean
