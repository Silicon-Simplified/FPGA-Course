# make auto | regions | tight   - one floorplan (about 1.5 minutes each) -> reports/fp_<tag>.csv, lanes_<tag>.csv
# make incremental              - full vs incremental compile of a one-inverter change (run `make auto` first; needs a path without spaces)
auto regions tight:
	vivado -mode batch -nojournal -nolog -source scripts/fp.tcl -tclargs $@ rtl/fp_demo.v $@
incremental:
	vivado -mode batch -nojournal -nolog -source scripts/fp.tcl -tclargs mod_full rtl/fp_demo_mod.v auto
	vivado -mode batch -nojournal -nolog -source scripts/fp.tcl -tclargs mod_incr rtl/fp_demo_mod.v auto build/auto.dcp
clean:
	rm -rf build .Xil clockInfo.txt
.PHONY: auto regions tight incremental clean
