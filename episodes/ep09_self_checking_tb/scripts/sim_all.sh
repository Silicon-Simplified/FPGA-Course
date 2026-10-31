#!/usr/bin/env bash
# The whole xsim flow for each testbench: compile (xvlog), elaborate (xelab), run (xsim -R).  Usage: bash scripts/sim_all.sh
set -e
cd "$(dirname "$0")/.."
mkdir -p .sim reports && cd .sim
: > ../reports/timing.txt
now() { date +%s.%N; }
run() {                                     # run <top> <files...>
    top=$1; shift
    t0=$(now); xvlog "$@" > /dev/null
    t1=$(now); xelab $top -s ${top}_sim > /dev/null
    t2=$(now); xsim ${top}_sim -R 2>&1 | grep -E "PASS|FAIL|DIRECTED|RANDOM|EXHAUSTIVE|PIPE|SEEDS"
    t3=$(now)
    printf "TIME %s xvlog=%.1f xelab=%.1f xsim=%.1f (seconds)\n" $top $(echo "$t1 - $t0" | bc -l) $(echo "$t2 - $t1" | bc -l) $(echo "$t3 - $t2" | bc -l) | tee -a ../reports/timing.txt
}
run tb_directed   ../rtl/adder4.v ../rtl/alu4.v ../rtl/alu4_bug.v ../tb/tb_directed.v
run tb_random     ../rtl/adder4.v ../rtl/alu4.v ../rtl/alu4_bug.v ../tb/tb_random.v
run tb_seeds      ../rtl/adder4.v ../rtl/alu4_bug.v ../tb/tb_seeds.v
run tb_exhaustive ../rtl/adder4.v ../rtl/alu4.v ../rtl/alu4_bug.v ../tb/tb_exhaustive.v
run tb_pipe       ../rtl/add_pipe.v ../rtl/add_pipe_bad.v ../tb/tb_pipe.v
cp wave.vcd ../reports/wave_pipe.vcd
