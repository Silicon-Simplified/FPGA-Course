#!/usr/bin/env bash
# Run every self-checking testbench with the Vivado simulator (xsim).  Usage: bash scripts/sim_all.sh
set -e
cd "$(dirname "$0")/.."
mkdir -p .sim reports && cd .sim
run() { top=$1; shift; xvlog "$@" >/dev/null && xelab $top -s ${top}_sim >/dev/null && xsim ${top}_sim -R 2>&1 | grep -E "PASS|FAIL|RST|BLINK"; }
run tb_counter ../rtl/cnt8_sync.v ../rtl/cnt8_async.v ../tb/tb_counter.v; cp wave.vcd ../reports/wave_counter.vcd
run tb_shreg   ../rtl/shreg_rst.v ../rtl/shreg_norst.v ../rtl/shreg_arst.v ../tb/tb_shreg.v
run tb_rstsync ../rtl/rst_sync.v ../tb/tb_rstsync.v; cp wave.vcd ../reports/wave_rstsync.vcd
run tb_blink   ../rtl/tick_gen.v ../rtl/blink_en.v ../rtl/blink_div.v ../tb/tb_blink.v; cp wave.vcd ../reports/wave_blink.vcd
