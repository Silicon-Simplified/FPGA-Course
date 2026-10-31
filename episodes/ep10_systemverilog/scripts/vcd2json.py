#!/usr/bin/env python3
"""Convert the top-level signals of an xsim VCD into JSON events: {name: {"w": width, "ev": [[t_ns, value], ...]}, "end": t_ns}.
Usage: python3 scripts/vcd2json.py reports/wave_counter.vcd reports/wave_counter.json
Unknown (x/z) values are written as -1."""
import json
import sys


def convert(src, dst):
    scale_ps, scope, sigs, ev = 1.0, [], {}, {}
    ids, t, end = {}, 0.0, 0.0
    lines = open(src).read().split("\n")
    i = 0
    while i < len(lines):
        ln = lines[i].strip()
        i += 1
        if ln.startswith("$timescale"):
            body = " ".join(lines[i - 1:i + 1])
            scale_ps = {"1ps": 1.0, "1ns": 1000.0, "10ps": 10.0, "100ps": 100.0}.get(body.replace("$timescale", "").replace("$end", "").replace(" ", ""), 1.0)
        elif ln.startswith("$scope"):
            scope.append(ln.split()[2])
        elif ln.startswith("$upscope"):
            scope.pop()
        elif ln.startswith("$var") and len(scope) == 1:
            p = ln.split()
            ids[p[3]] = (p[4], int(p[2]))
            ev[p[4]] = []
        elif ln.startswith("#"):
            t = int(ln[1:]) * scale_ps / 1000.0
            end = max(end, t)
        elif ln and ln[0] in "01xzXZ" and ln[1:] in ids:
            n = ids[ln[1:]][0]
            ev[n].append([t, -1 if ln[0] in "xzXZ" else int(ln[0])])
        elif ln.startswith("b"):
            val, ident = ln[1:].split()
            if ident in ids:
                ev[ids[ident][0]].append([t, -1 if set(val) & set("xzXZ") else int(val, 2)])
    out = {n: {"w": w, "ev": ev[n]} for n, w in ids.values()}
    out["end"] = end
    json.dump(out, open(dst, "w"))


if __name__ == "__main__":
    convert(sys.argv[1], sys.argv[2])
