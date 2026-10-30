#!/usr/bin/env bash
# Run every self-checking testbench with the Vivado simulator (xsim). Usage: bash scripts/sim_all.sh
set -e
cd "$(dirname "$0")/.."
mkdir -p .sim && cd .sim
run() { top=$1; shift; xvlog "$@" >/dev/null && xelab $top -s ${top}_sim >/dev/null && xsim ${top}_sim -R 2>&1 | grep -E "PASS|FAIL"; }
run tb_adder ../rtl/adder.v ../rtl/adder_co.v ../tb/tb_adder.v
run tb_srl   ../rtl/srl_delay.v ../rtl/srl_var.v ../tb/tb_srl.v
run tb_dram  ../rtl/dram64x8.v ../rtl/dram64x8_sp.v ../tb/tb_dram.v
run tb_wide  ../rtl/wide7.v ../rtl/wide8.v ../tb/tb_wide.v
run tb_dual  ../rtl/dual_lut.v ../tb/tb_dual.v
# LUT6_2 primitive needs the UNISIM library
xvlog ../rtl/dual_lut_prim.v ../tb/tb_dual_prim.v >/dev/null && xvlog $XILINX_VIVADO/data/verilog/src/glbl.v >/dev/null && \
  xelab tb_dual_prim glbl -L unisims_ver -s tb_dual_prim_sim >/dev/null && xsim tb_dual_prim_sim -R 2>&1 | grep -E "PASS|FAIL"
