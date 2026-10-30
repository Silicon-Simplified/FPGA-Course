#!/usr/bin/env bash
# Lint every design with Verilator (each file with only the modules it needs).
cd "$(dirname "$0")/.."
W="-Wall -Wno-DECLFILENAME -Wno-UNUSEDSIGNAL"
for f in adder4; do verilator --lint-only $W rtl/$f.v; done
for f in alu4 ; do verilator --lint-only $W rtl/adder4.v rtl/$f.v; done
for f in alu4_reg alu_top; do verilator --lint-only $W --top-module $f rtl/adder4.v rtl/alu4.v rtl/$f.v; done
for f in latch_fixed order_a order_b ops_demo; do verilator --lint-only $W rtl/$f.v; done
echo "(latch_bug is meant to warn:)"; verilator --lint-only $W rtl/latch_bug.v 2>&1 | grep -E "LATCH" | head -1
