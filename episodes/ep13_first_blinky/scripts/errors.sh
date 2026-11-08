#!/usr/bin/env bash
# The three mistakes every beginner makes, reproduced on purpose.   Usage: bash scripts/errors.sh   (writes reports/err1..3.txt)
cd "$(dirname "$0")/.."
source "${VIVADO_SETTINGS:-$HOME/xilinx/Vivado/2023.2/settings64.sh}" >/dev/null 2>&1
mkdir -p reports .errwork
run() {   # run <name> <xdc-or-none> <extra tcl before bitstream>
  n=$1; x=$2
  { echo "read_verilog rtl/blinky.v"
    [ "$x" != none ] && echo "read_xdc $x"
    echo "synth_design -top blinky -part xc7z020clg400-1"
    echo "opt_design"
    echo "place_design"
    echo "route_design"
    echo "puts \"CHECK_TIMING_BEGIN\"; puts [check_timing -return_string]; puts \"CHECK_TIMING_END\""
    echo "if {[catch {write_bitstream -force .errwork/$n.bit} e]} { puts \"BITSTREAM_FAILED\" } else { puts \"BITSTREAM_OK\" }"
  } > .errwork/$n.tcl
  vivado -mode batch -nojournal -nolog -source .errwork/$n.tcl > .errwork/$n.log 2>&1
  grep -E "ERROR: \[|CRITICAL WARNING: \[|BITSTREAM_|no_clock|There are [0-9]+ register/latch pins with no clock|unconstrained" .errwork/$n.log | sed -E 's#/[^ ]*/(rtl|constraints|scripts)/#\1/#g; s#\[[^]]*\.(xdc|tcl):[0-9]+\]##' | awk '!seen[$0]++' | head -14 > reports/$n.txt
}
# 1) no constraints file at all
run err1 none
# 2) pins constrained, but no create_clock
sed '/create_clock/d' constraints/pynq_z2_blinky.xdc > .errwork/noclock.xdc
run err2 .errwork/noclock.xdc
# 3) a typo in a port name (leds instead of led)
sed 's/get_ports {led\[0\]}/get_ports {leds[0]}/' constraints/pynq_z2_blinky.xdc > .errwork/typo.xdc
run err3 .errwork/typo.xdc
cat reports/err1.txt reports/err2.txt reports/err3.txt | head -0
rm -rf .Xil
