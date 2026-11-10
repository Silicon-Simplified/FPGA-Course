# make synth   - synthesize every variant (about 3 minutes) -> reports/variants.csv
# make sim     - read-during-write + latency, and the DDS spectrum (Verilator + numpy; run from a folder whose path has NO spaces)
synth:
	vivado -mode batch -nojournal -nolog -source scripts/synth_variants.tcl
bramtiming:
	vivado -mode batch -nojournal -nolog -source scripts/bram_timing.tcl
sim:
	mkdir -p build/rtl && cp rtl/sine1024.hex build/rtl/ && cd build && verilator --binary --timing -Wno-fatal -Wno-lint -Wno-style --top-module tb_rw ../rtl/ram_variants.v ../tb/tb_rw.v > vl1.log && ./obj_dir/Vtb_rw
	cd build && verilator --binary --timing -Wno-fatal -Wno-lint -Wno-style --top-module tb_dds -Mdir obj_dds ../rtl/ram_variants.v ../tb/tb_dds.v > vl2.log && ./obj_dds/Vtb_dds +K=33292288 +N=16384 +OUT=coh.txt && python3 ../scripts/analyze_dds.py coh.txt 33292288 dds_coherent
clean:
	rm -rf build .Xil clockInfo.txt
.PHONY: synth bramtiming sim clean
