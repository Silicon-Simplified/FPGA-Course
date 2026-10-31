#!/usr/bin/env bash
# Verilator lint.  The three "bad" files are SUPPOSED to produce warnings - that is the point of the episode.
cd "$(dirname "$0")/.."
for f in fsm_traffic_sv; do verilator --lint-only -Wall rtl/$f.sv --top-module $f && echo "LINT OK $f"; done
verilator --lint-only -Wall rtl/alu_pkg.sv rtl/alu4_sv.sv --top-module alu4_sv && echo "LINT OK alu4_sv"
verilator --lint-only -Wall rtl/if_stream.sv rtl/stream_slice.sv rtl/stream_slice_top.sv --top-module stream_slice_top && echo "LINT OK stream_slice_top"
for f in latch_comb blk_ff multi_drv; do echo "--- $f"; verilator --lint-only -Wall rtl/$f.sv --top-module $f 2>&1 | grep -E "^%(Warning|Error)" | head -3; done
