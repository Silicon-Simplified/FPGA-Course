# make sta - implement the tiny design once and dump its setup/hold paths at four clock periods -> reports/paths.csv, setup_path.rpt, hold_path.rpt (about 1 minute)
sta:
	vivado -mode batch -nojournal -nolog -source scripts/sta.tcl
clean:
	rm -rf .Xil
.PHONY: sta clean
