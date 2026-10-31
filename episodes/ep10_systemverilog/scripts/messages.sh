#!/usr/bin/env bash
# What does the simulator's compiler say about two always_ff blocks driving one variable?  -> reports/xvlog_multi_drv.txt
cd "$(dirname "$0")/.."
mkdir -p .sim && cd .sim
xvlog -sv ../rtl/multi_drv.sv 2>&1 | grep -E "ERROR|WARNING" > ../reports/xvlog_multi_drv.txt
xvlog -sv ../rtl/multi_drv.sv > /dev/null 2>&1 && xelab multi_drv -s md 2>&1 | grep -E "ERROR|WARNING" >> ../reports/xvlog_multi_drv.txt
cat ../reports/xvlog_multi_drv.txt
