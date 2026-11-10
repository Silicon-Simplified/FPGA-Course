#!/usr/bin/env python3
"""Episode 27: analyse the DDS samples written by tb/tb_dds.v. Usage: python3 scripts/analyze_dds.py <samples.txt> <K> <out_prefix>"""
import sys
import numpy as np
f, K, out = sys.argv[1], int(sys.argv[2]), sys.argv[3]
x = np.loadtxt(f)
FCLK = 125e6
fexp = FCLK * K / 2 ** 32
# measured frequency from rising zero crossings
z = np.where((x[:-1] < 0) & (x[1:] >= 0))[0]
fmeas = FCLK * (len(z) - 1) / (z[-1] - z[0]) if len(z) > 2 else float("nan")
res = dict(samples=len(x), K=K, f_expected_hz=round(fexp, 3), f_measured_hz=round(fmeas, 1), max=int(x.max()), min=int(x.min()))
if len(x) == 16384:                                     # coherent sampling: K = 2^32 * 127 / 16384, no window needed
    X = np.abs(np.fft.rfft(x)) / (len(x) / 2)
    X[0] = 0
    peak = X.argmax()
    db = 20 * np.log10(np.maximum(X, 1e-12) / X[peak])
    spur = db.copy(); spur[peak] = -999
    s = int(spur.argmax())
    res.update(fundamental_bin=int(peak), sfdr_dbc=round(-float(spur[s]), 2), worst_spur_bin=s)
    np.savetxt(out + "_spectrum.csv", np.column_stack([np.arange(len(db)), db]), delimiter=",", header="bin,dbc", comments="", fmt=["%d", "%.2f"])
with open(out + "_summary.txt", "w") as fh:
    for k_, v in res.items():
        fh.write(f"{k_}={v}\n")
print(res)
