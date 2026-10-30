#!/usr/bin/env bash
# Run every self-checking testbench with the Vivado simulator (xsim). Usage: bash scripts/sim_all.sh
set -e
cd "$(dirname "$0")/.."
mkdir -p .sim && cd .sim
run() { top=$1; shift; xvlog "$@" >/dev/null && xelab $top -s ${top}_sim >/dev/null && xsim ${top}_sim -R 2>&1 | grep -E "PASS|FAIL|MISMATCH"; }
run tb_fa           ../rtl/fa_gates.v ../rtl/fa_rtl.v ../tb/tb_fa.v
run tb_comb_vs_seq  ../rtl/comb_vs_seq.v ../tb/tb_comb_vs_seq.v
cp wave.vcd ../reports/wave.vcd 2>/dev/null || true
