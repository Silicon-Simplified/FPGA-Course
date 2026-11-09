# make gen      - regenerate rtl/pipe_N.v and rtl/retime_demo.v
# make run      - run every variant (about 8 minutes) -> reports/fix_*.csv
gen:
	python3 scripts/gen.py
run:
	bash scripts/run_all.sh
clean:
	rm -rf .Xil clockInfo.txt
.PHONY: gen run clean
