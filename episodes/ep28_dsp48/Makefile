# make variants - the multiplier variants (about 5 minutes) -> reports/dsp_variants.csv
# make fir      - generate the FIR (scripts/gen_fir.py), implement both forms -> reports/fir_impl.csv
# make sim      - simulate the FIR and compare with numpy (Verilator + numpy; run from a folder whose path has NO spaces)
variants:
	vivado -mode batch -nojournal -nolog -source scripts/dsp_variants.tcl
fir:
	python3 scripts/gen_fir.py
	vivado -mode batch -nojournal -nolog -source scripts/fir_impl.tcl
sim:
	mkdir -p build && cp reports/fir_stimulus.txt build/fir_in.txt && cd build && verilator --binary --timing -Wno-fatal -Wno-lint -Wno-style --top-module tb_fir ../rtl/fir8.v ../tb/tb_fir.v > vl.log && ./obj_dir/Vtb_fir && python3 ../scripts/check_fir.py fir_in.txt fir_out.txt ../reports/fir_coeffs.txt fir_check.txt
clean:
	rm -rf build .Xil clockInfo.txt
.PHONY: variants fir sim clean
