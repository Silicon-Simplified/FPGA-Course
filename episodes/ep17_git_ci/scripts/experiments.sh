#!/usr/bin/env bash
# Episode 17 experiments (Vivado 2023.2, PYNQ-Z2 part).  Works in a scratch directory WITHOUT spaces in its path.
#   A  project mode, what would git see?   B  write_project_tcl, regenerate   C  template: git clone -> make bit twice, compare
# Usage: bash scripts/experiments.sh [scratch-dir]
HERE="$(cd "$(dirname "$0")/.." && pwd)"
W="${1:-/tmp/ep17_work}"
source "${VIVADO_SETTINGS:-$HOME/xilinx/Vivado/2023.2/settings64.sh}" >/dev/null 2>&1
rm -rf "$W"; mkdir -p "$W" "$HERE/reports"; cd "$W"
git config --global user.email >/dev/null 2>&1 || { git config --global user.email "course@example.com"; git config --global user.name "Course"; }

# ---------------- A: project mode ----------------
mkdir -p A/src && cp "$HERE/template/rtl/blinky.v" "$HERE/template/constraints/pynq_z2.xdc" A/src/
cat > A/mk.tcl <<'TCL'
create_project proj proj -part xc7z020clg400-1 -force
add_files src/blinky.v
add_files -fileset constrs_1 src/pynq_z2.xdc
set_property top blinky [current_fileset]
launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1
write_project_tcl -force -no_copy_sources recreate.tcl
TCL
(cd A && vivado -mode batch -nojournal -nolog -source mk.tcl > mk.log 2>&1)
cd A; git init -q; git add -A; cd ..
A_ALL_FILES=$(cd A && git ls-files | wc -l); A_ALL_BYTES=$(cd A && git ls-files -z | xargs -0 du -cb 2>/dev/null | tail -1 | cut -f1)
cp "$HERE/template/.gitignore" A/.gitignore; (cd A && git rm -r -q --cached . && git add -A)
A_IGN_FILES=$(cd A && git ls-files | wc -l); A_IGN_LIST=$(cd A && git ls-files | tr '\n' ' ')
A_XPR_ABS=$(grep -c "$W" A/proj/proj.xpr)
A_XPR_BYTES=$(stat -c %s A/proj/proj.xpr)
# ---------------- B: regenerate ----------------
RECREATE_LINES=$(wc -l < A/recreate.tcl); RECREATE_BYTES=$(stat -c %s A/recreate.tcl)
mkdir -p B/src && cp A/src/* B/src/ && cp A/recreate.tcl B/ && cd B
vivado -mode batch -nojournal -nolog -source recreate.tcl > re.log 2>&1
B_OK=$(grep -c "create_project: Time" re.log)
cd ..
# ---------------- C: template -> clone -> build ----------------
cp -r "$HERE/template" T && cd T && git init -q && git add -A && git commit -q -m "template" && cd ..
C_TRACKED=$(cd T && git ls-files | wc -l); C_TRACKED_BYTES=$(cd T && git ls-files -z | xargs -0 du -cb | tail -1 | cut -f1)
git clone -q T T_clone
(cd T && make bit > build.out 2>&1); (cd T_clone && make bit > build.out 2>&1)
cp T/build/result.csv "$HERE/reports/result_original.csv"; cp T_clone/build/result.csv "$HERE/reports/result_clone.csv"
HASH=$(cd T && git rev-parse HEAD | cut -c1-8)
python3 - "$W" "$HASH" > "$HERE/reports/bitstream_check.txt" <<'PY'
import sys
w, h = sys.argv[1], sys.argv[2]
b1 = open(f"{w}/T/build/blinky.bit", "rb").read(); b2 = open(f"{w}/T_clone/build/blinky.bit", "rb").read()
diff = [i for i in range(min(len(b1), len(b2))) if b1[i] != b2[i]]
print(f"bytes_original={len(b1)} bytes_clone={len(b2)} differing_bytes={len(diff)} first_diff={diff[0] if diff else -1} last_diff={diff[-1] if diff else -1}")
print(f"commit_prefix={h} usr_access_in_bitstream={bytes.fromhex(h) in b1}")
PY
( cd T && make lint > ../lint.out 2>&1; echo "lint_exit=$?" >> ../lint.out; make test > ../test.out 2>&1; echo "test_exit=$?" >> ../test.out )
{ echo "key,value"
  echo "projmode_files_git_add_all,$A_ALL_FILES"; echo "projmode_bytes_git_add_all,$A_ALL_BYTES"
  echo "projmode_files_with_gitignore,$A_IGN_FILES"; echo "projmode_xpr_bytes,$A_XPR_BYTES"; echo "projmode_xpr_absolute_path_lines,$A_XPR_ABS"
  echo "recreate_tcl_lines,$RECREATE_LINES"; echo "recreate_tcl_bytes,$RECREATE_BYTES"; echo "regenerated_ok,$B_OK"
  echo "template_tracked_files,$C_TRACKED"; echo "template_tracked_bytes,$C_TRACKED_BYTES"
  echo "lint,$(tail -1 lint.out 2>/dev/null)"; echo "test,$(tail -1 test.out 2>/dev/null)"; } > "$HERE/reports/git_numbers.csv"
echo "$A_IGN_LIST" > "$HERE/reports/projmode_tracked_with_gitignore.txt"
(cd T && git ls-files > "$HERE/reports/template_files.txt")
echo ALL_DONE
