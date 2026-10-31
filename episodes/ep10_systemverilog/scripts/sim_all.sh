#!/usr/bin/env bash
# Run every self-checking SystemVerilog testbench with xsim.  Usage: bash scripts/sim_all.sh
set -e
cd "$(dirname "$0")/.."
mkdir -p .sim reports && cd .sim
run() { top=$1; shift; xvlog -sv "$@" >/dev/null && xelab $top -s ${top}_sim >/dev/null && xsim ${top}_sim -R 2>&1 | grep -E "PASS|FAIL|STATE|TRAFFIC|ALU|STREAM|ERROR|Error"; }
run tb_traffic_sv ../rtl/fsm_traffic.v ../rtl/fsm_traffic_sv.sv ../tb/tb_traffic_sv.sv;   cp wave.vcd ../reports/wave_traffic.vcd
run tb_alu_sv     ../rtl/adder4.v ../rtl/alu4.v ../rtl/alu_pkg.sv ../rtl/alu4_sv.sv ../tb/tb_alu_sv.sv
run tb_stream     ../rtl/if_stream.sv ../rtl/stream_slice.sv ../tb/tb_stream.sv;          cp wave.vcd ../reports/wave_stream.vcd
