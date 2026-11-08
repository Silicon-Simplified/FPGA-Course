# make sim   - self-checking simulation (xsim)
# make bit   - synthesis, implementation, bitstream  ->  out/blinky.bit  + reports/
# make prog  - program the board over JTAG (untested on hardware here)
VIVADO ?= vivado
sim:
	bash scripts/sim.sh
bit:
	$(VIVADO) -mode batch -nojournal -log reports/build.log -source scripts/build.tcl
prog: out/blinky.bit
	$(VIVADO) -mode batch -nojournal -log reports/prog.log -source scripts/prog.tcl
clean:
	rm -rf out reports/build.log reports/prog.log .sim .Xil
.PHONY: sim bit prog clean
