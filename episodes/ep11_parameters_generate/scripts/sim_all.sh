#!/usr/bin/env bash
# Run every self-checking testbench with xsim.  Usage: bash scripts/sim_all.sh
set -e
cd "$(dirname "$0")/.."
mkdir -p .sim reports && cd .sim
run() { top=$1; shift; xvlog -sv "$@" >/dev/null && xelab $top -s ${top}_sim >/dev/null && xsim ${top}_sim -R 2>&1 | grep -E "PASS|FAIL|WIDTH|LEDBAR|ADDERS|ERROR"; }
run tb_widths ../rtl/cnt_n.v ../tb/tb_widths.sv
run tb_ledbar ../rtl/led_bar.v ../tb/tb_ledbar.sv
run tb_adders ../rtl/full_adder.v ../rtl/rca_gen.v ../rtl/add_plus.v ../tb/tb_adders.sv
