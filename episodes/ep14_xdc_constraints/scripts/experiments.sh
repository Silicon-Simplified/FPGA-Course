#!/usr/bin/env bash
# Episode 14 experiments: one design (rtl/blinky.v), different constraints.   Usage: bash scripts/experiments.sh
cd "$(dirname "$0")/.."
source "${VIVADO_SETTINGS:-$HOME/xilinx/Vivado/2023.2/settings64.sh}" >/dev/null 2>&1
mkdir -p reports .work
CLEAN='s#/[^ ]*/(rtl|constraints|scripts)/#\1/#g; s#\[[^]]*\.(xdc|tcl):[0-9]+\]##'
run() {   # run <name> <xdc> ; implement (no bitstream), then try the bitstream, print IO table + timing + DRC
  n=$1; x=$2
  { echo "read_verilog rtl/blinky.v"; echo "read_xdc $x"
    echo "synth_design -top blinky -part xc7z020clg400-1"
    echo "opt_design"; echo "place_design"; echo "route_design"
    echo "puts \"WNS=[get_property SLACK [get_timing_paths -max_paths 1 -setup]]\""
    echo "report_io -file .work/$n.io"
    echo "if {[catch {write_bitstream -force .work/$n.bit} e]} { puts \"BITSTREAM_FAILED\" } else { puts \"BITSTREAM_OK\" }"
  } > .work/$n.tcl
  vivado -mode batch -nojournal -nolog -source .work/$n.tcl > .work/$n.log 2>&1
}
# 0) baseline: the Episode 13 constraints
run base constraints/base.xdc
# 1) one pin in bank 35 asked for 1.8 V while the clock pin in the same bank is 3.3 V
sed 's/{ PACKAGE_PIN N16 IOSTANDARD LVCMOS33 }/{ PACKAGE_PIN N16 IOSTANDARD LVCMOS18 }/' constraints/base.xdc > .work/mixed.xdc
# 2) pin that does not exist on this package
sed 's/PACKAGE_PIN R14/PACKAGE_PIN Z99/' constraints/base.xdc > .work/nopin.xdc
# 3) two ports on one pin
sed 's/PACKAGE_PIN P14/PACKAGE_PIN R14/' constraints/base.xdc > .work/dup.xdc
# 4) drive / slew / pull properties
{ cat constraints/base.xdc
  echo 'set_property DRIVE 4 [get_ports {led[*]}]'
  echo 'set_property SLEW FAST [get_ports {led[*]}]'
  echo 'set_property PULLTYPE PULLDOWN [get_ports btn]'; } > .work/props.xdc
for v in mixed nopin dup props; do run $v .work/$v.xdc & done; wait
# 5) clock period sweep: same design, tighter and tighter create_clock
for p in 8.000 5.000 4.000 3.000 2.500; do
  sed "s/-period 8.000/-period $p/" constraints/base.xdc > .work/p$p.xdc
done
for p in 8.000 5.000 4.000; do run p$p .work/p$p.xdc & done; wait
for p in 3.000 2.500; do run p$p .work/p$p.xdc & done; wait
# 6) the same pins written as Tcl loops: a .tcl file that is sourced (read_xdc rejects 'for', see reports/x_for.txt)
printf 'read_verilog rtl/blinky.v\nsynth_design -top blinky -part xc7z020clg400-1\nsource constraints/pins_loop.tcl\nopt_design\nplace_design\nreport_io -file .work/loop.io\n' > .work/loop.tcl
vivado -mode batch -nojournal -nolog -source .work/loop.tcl > .work/loop.log 2>&1
# collect
for n in nopin dup; do grep -a -E "^(ERROR: \[|CRITICAL WARNING: \[|BITSTREAM_)" .work/$n.log | sed -E "$CLEAN" | awk '!seen[$0]++' | head -8 > reports/x_$n.txt; done
{ grep -a -A1 "DRC BIVC-1" .work/mixed.log | head -2 | sed -E 's/  *$//'; echo "ERROR: [Vivado_Tcl 4-23] Error(s) found during DRC. Placer not run."; } > reports/x_mixed.txt
cp constraints/pins_loop.tcl .work/for_as.xdc
printf 'read_verilog rtl/blinky.v\nread_xdc .work/for_as.xdc\nsynth_design -top blinky -part xc7z020clg400-1\n' > .work/forx.tcl
vivado -mode batch -nojournal -nolog -source .work/forx.tcl > .work/forx.log 2>&1
grep -a "20-1307" .work/forx.log | sed -E 's# \[[^]]*:[0-9]+\]##' | awk '!s[$0]++' > reports/x_for.txt
{ echo "period_ns,wns_ns,bitstream"; for p in 8.000 5.000 4.000 3.000 2.500; do
    echo "$p,$(grep -a '^WNS=' .work/p$p.log | tail -1 | cut -d= -f2),$(grep -ao 'BITSTREAM_[A-Z]*' .work/p$p.log | tail -1)"; done; } > reports/period_sweep.csv
for n in base props loop; do awk -F'|' '/^\| (H16|D19|M20|M19|R14|P14|N16|M14) /{gsub(/ /,"");print $3","$7","$8","$9","$10","$15}' .work/$n.io | sort > reports/io_$n.csv; done
rm -rf .Xil
