# Digital down-converter - Episode 41. Needs python3 with numpy + scipy and Verilator 5 for `test`; Vivado 2023.2 on PATH for `build`.
.PHONY: tables test build clean
tables:
	python3 tools/ddc_model.py gen
test:
	python3 tools/ddc_model.py test
build:
	mkdir -p work/reports && cp rtl/*.mem work/ && cp -r rtl scripts work/ && cd work && vivado -mode batch -source scripts/build.tcl && cp reports/* ../reports/
clean:
	rm -rf work *.jou *.log .Xil
