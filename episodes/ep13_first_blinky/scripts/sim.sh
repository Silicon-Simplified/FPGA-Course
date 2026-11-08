#!/usr/bin/env bash
# Self-checking simulation:  bash scripts/sim.sh
set -e
cd "$(dirname "$0")/.."
mkdir -p .sim reports && cd .sim
xvlog ../rtl/blinky.v ../tb/tb_blinky.v > /dev/null && xelab tb_blinky -s tb_sim > /dev/null && xsim tb_sim -R 2>&1 | grep -E "SPEED|PASS|FAIL" | tee ../reports/sim_output.txt
cp wave.vcd ../reports/wave.vcd
