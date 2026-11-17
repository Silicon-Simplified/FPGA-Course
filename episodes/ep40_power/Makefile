# Power experiments - Episode 40. Vivado 2023.2 on PATH (source settings64.sh); xvlog/xelab/xsim come with it. Takes about 35 minutes.
.PHONY: run clean
run:
	vivado -mode batch -source scripts/run.tcl
clean:
	rm -rf sim work_* snap_* xsim.dir *.jou *.log *.pb .Xil
