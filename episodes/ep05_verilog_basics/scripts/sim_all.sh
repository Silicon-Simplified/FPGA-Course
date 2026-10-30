#!/usr/bin/env bash
# Run every self-checking testbench with the Vivado simulator (xsim).  Usage: bash scripts/sim_all.sh
set -e
cd "$(dirname "$0")/.."
mkdir -p .sim && cd .sim
run() { top=$1; shift; xvlog "$@" >/dev/null && xelab $top -s ${top}_sim >/dev/null && xsim ${top}_sim -R 2>&1 | grep -E "PASS|FAIL|ROW|OPS"; }
run tb_alu4  ../rtl/adder4.v ../rtl/alu4.v ../tb/tb_alu4.v
run tb_ops   ../rtl/ops_demo.v ../tb/tb_ops.v
run tb_order ../rtl/order_a.v ../rtl/order_b.v ../tb/tb_order.v
