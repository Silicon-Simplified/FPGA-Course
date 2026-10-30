#!/usr/bin/env bash
# Verilator lint of every module.  Usage: bash scripts/lint.sh
cd "$(dirname "$0")/.."
for f in rtl/cnt8_sync rtl/cnt8_async rtl/shreg_rst rtl/shreg_norst rtl/shreg_arst rtl/rst_sync rtl/tick_gen; do
  m=$(basename $f); verilator --lint-only -Wall -Wno-DECLFILENAME -Wno-UNUSEDSIGNAL $f.v --top-module $m && echo "LINT OK $m"
done
verilator --lint-only -Wall -Wno-DECLFILENAME rtl/tick_gen.v rtl/blink_en.v --top-module blink_en && echo "LINT OK blink_en"
verilator --lint-only -Wall -Wno-DECLFILENAME rtl/blink_div.v --top-module blink_div && echo "LINT OK blink_div"
