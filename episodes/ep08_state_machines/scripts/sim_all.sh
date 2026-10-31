#!/usr/bin/env bash
# Run every self-checking testbench with the Vivado simulator (xsim).  Usage: bash scripts/sim_all.sh
set -e
cd "$(dirname "$0")/.."
mkdir -p .sim reports && cd .sim
run() { top=$1; shift; xvlog "$@" >/dev/null && xelab $top -s ${top}_sim >/dev/null && xsim ${top}_sim -R 2>&1 | grep -E "PASS|FAIL|SEQ|SEU|DEBOUNCE"; }
run tb_traffic  ../rtl/fsm_traffic.v ../tb/tb_traffic.v;                      cp wave.vcd ../reports/wave_traffic.vcd
run tb_seq      ../rtl/seq_mealy.v ../rtl/seq_moore.v ../tb/tb_seq.v;          cp wave.vcd ../reports/wave_seq.vcd
run tb_safe     ../rtl/fsm_unsafe.v ../rtl/fsm_safe.v ../tb/tb_safe.v;         cp wave.vcd ../reports/wave_safe.vcd
run tb_debounce ../rtl/debounce.v ../tb/tb_debounce.v;                         cp wave.vcd ../reports/wave_debounce.vcd
