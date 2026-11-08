#!/usr/bin/env bash
# Self-checking simulation with the Vivado simulator:  bash scripts/sim.sh   (output in build/sim/)
set -e
cd "$(dirname "$0")/.."
mkdir -p build/sim && cd build/sim
xvlog ../../rtl/*.v ../../tb/*.v > /dev/null && xelab tb_blinky -s tb_sim > /dev/null && xsim tb_sim -R 2>&1 | grep -E "SPEED|PASS|FAIL" | tee sim_output.txt
grep -q PASS sim_output.txt
