# make stages P=7.0 - run the implementation steps one at a time at a P ns clock (about 1.5 minutes)
P ?= 7.0
stages:
	vivado -mode batch -nojournal -log reports/stages_$(P).log -source scripts/stages.tcl -tclargs $(P)
clean:
	rm -rf .Xil reports/*.dcp
.PHONY: stages clean
