#!/usr/bin/env bash
# Run every self-checking testbench with the Vivado simulator (xsim).  Usage: bash scripts/sim_all.sh
set -e
cd "$(dirname "$0")/.."
mkdir -p .sim && cd .sim
run() { top=$1; shift; xvlog "$@" >/dev/null && xelab $top -s ${top}_sim >/dev/null && xsim ${top}_sim -R 2>&1 | grep -E "PASS|FAIL|SWAP|SENS"; }
run tb_shift ../rtl/shift3_nb.v ../rtl/shift3_blk.v ../tb/tb_shift.v
cp wave.vcd ../reports/wave.vcd
run tb_swap  ../rtl/swap_nb.v ../rtl/swap_blk.v ../tb/tb_swap.v
run tb_sens  ../rtl/sens_bad.v ../rtl/sens_good.v ../tb/tb_sens.v
