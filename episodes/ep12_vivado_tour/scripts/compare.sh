#!/usr/bin/env bash
# Run both flows from a clean directory and measure what each one leaves behind.   Usage: bash scripts/compare.sh
set -e
cd "$(dirname "$0")/.."
source "${VIVADO_SETTINGS:-$HOME/xilinx/Vivado/2023.2/settings64.sh}" >/dev/null 2>&1
mkdir -p reports
rm -rf work_np work_pm; mkdir work_np work_pm
for m in np pm; do
  cp -r rtl constraints scripts work_$m/
  mkdir -p work_$m/reports
done
( cd work_np && vivado -mode batch -source scripts/build_nonproject.tcl > reports/run.log 2>&1 )
( cd work_pm && vivado -mode batch -source scripts/build_project.tcl > reports/run.log 2>&1 )
: > reports/mode_compare.csv
echo "mode,seconds,wns_ns,luts,ffs,bit_bytes,files_created,dirs_created,kbytes_created" >> reports/mode_compare.csv
for m in np pm; do
  line=$(grep '^RESULT' work_$m/reports/run.log | tail -1)
  # what the run created, not counting the inputs we copied in (rtl, constraints, scripts, reports)
  files=$(find work_$m -mindepth 1 -type f ! -path "work_$m/rtl/*" ! -path "work_$m/constraints/*" ! -path "work_$m/scripts/*" ! -path "work_$m/reports/*" | wc -l)
  dirs=$(find work_$m -mindepth 1 -type d ! -path "work_$m/rtl*" ! -path "work_$m/constraints*" ! -path "work_$m/scripts*" ! -path "work_$m/reports*" | wc -l)
  kb=$(find work_$m -mindepth 1 -type f ! -path "work_$m/rtl/*" ! -path "work_$m/constraints/*" ! -path "work_$m/scripts/*" ! -path "work_$m/reports/*" -printf '%s\n' | awk '{s+=$1} END {printf "%d", s/1024}')
  sec=$(echo "$line" | sed -E 's/.*seconds=([0-9.]+).*/\1/'); wns=$(echo "$line" | sed -E 's/.*wns=(-?[0-9.]+).*/\1/')
  luts=$(echo "$line" | sed -E 's/.*luts=([0-9]+).*/\1/'); ffs=$(echo "$line" | sed -E 's/.*ffs=([0-9]+).*/\1/'); bit=$(echo "$line" | sed -E 's/.*bit_bytes=([0-9]+).*/\1/')
  echo "$m,$sec,$wns,$luts,$ffs,$bit,$files,$dirs,$kb" >> reports/mode_compare.csv
done
# are the two bitstreams the same bits? (the first 256 bytes are a header with the date and file name)
diffb=$(cmp -l -i 256 work_np/out_np/top_blink_en.bit work_pm/proj_pm/proj_pm.runs/impl_1/top_blink_en.bit 2>&1 | wc -l)
echo "bitstream bytes that differ after the 256-byte header: $diffb" | tee reports/bitstream_diff.txt
(cd work_np && head -c 256 out_np/top_blink_en.bit | strings | head -5) > reports/bit_header_strings_np.txt 2>/dev/null || true
cat reports/mode_compare.csv
