# Sobel edge detector - Episode 42. Needs python3 with numpy, scipy and Pillow, and Verilator 5 for `test`; Vivado 2023.2 on PATH for `build`.
# Run in a folder whose path has no spaces (Verilator); SOBEL_WORK selects the simulation folder (default work/ next to the code).
.PHONY: test build clean
test:
	python3 tools/sobel_model.py test
build:
	vivado -mode batch -source scripts/build.tcl
clean:
	rm -rf work *.jou *.log .Xil
