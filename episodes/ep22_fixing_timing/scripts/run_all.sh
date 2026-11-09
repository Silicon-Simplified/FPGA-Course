#!/usr/bin/env bash
# Episode 22: every variant at 125 MHz (8 ns), clock constrained BEFORE synthesis. Run from the code/ folder, in a path without spaces for the simulation.
cd "$(dirname "$0")/.."
source "${VIVADO_SETTINGS:-$HOME/xilinx/Vivado/2023.2/settings64.sh}" >/dev/null 2>&1
mkdir -p .logs
run() { vivado -mode batch -nojournal -nolog -source scripts/fix.tcl -tclargs "$@" > .logs/$2.out 2>&1; }
run fail_demo f0 "" "" clk.xdc & run pipe_0 p0 & run pipe_1 p1 & wait
run pipe_2 p2 & run pipe_3 p3 & run pipe_4 p4 & wait
run pipe_0 p0_directives directives & run retime_demo r_plain & run retime_demo r_retime retiming & wait
run fanout_demo fo_plain "" "" clk3.xdc & run fanout_demo_mf fo_mf "" "" clk3.xdc & wait
rm -rf .Xil clockInfo.txt
