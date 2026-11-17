#!/usr/bin/env python3
"""Episode 41 - bit-exact model of the DDC, test-signal generator and spectrum analysis.
usage: python3 tools/ddc_model.py gen            (writes rtl/nco_cos.mem, rtl/nco_sin.mem, rtl/fir_coef.mem)
       python3 tools/ddc_model.py test [--mut]   (runs the Verilator simulations in a work folder and writes reports/sim_ddc.txt; needs verilator)"""
import os
import subprocess
import sys

import numpy as np
from scipy import signal

HERE = os.path.dirname(os.path.abspath(__file__))
CODE = os.path.join(HERE, "..")
FS, FC = 100e6, 10.7e6
INC = int(round(FC / FS * 2 ** 32))
assert INC == 459561501
R, NCIC, NT, DEC, FOUT = 50, 3, 31, 4, 100e6 / 50 / 4


def tables():
    i = np.arange(4096)
    ct = np.round(32767 * np.cos(2 * np.pi * i / 4096)).astype(np.int64)
    st = np.round(-32767 * np.sin(2 * np.pi * i / 4096)).astype(np.int64)             # -sin: mixing with (cos, -sin) moves +fc to 0 Hz
    h = np.round(signal.firwin(NT, 250e3, window=("kaiser", 6.5), fs=2e6) * 32768).astype(np.int64)
    return ct, st, h


def hex16(v):
    return "\n".join(f"{int(x) & 0xFFFF:04x}" for x in v) + "\n"


def gen():
    ct, st, h = tables()
    open(os.path.join(CODE, "rtl", "nco_cos.mem"), "w").write(hex16(ct))
    open(os.path.join(CODE, "rtl", "nco_sin.mem"), "w").write(hex16(st))
    open(os.path.join(CODE, "rtl", "fir_coef.mem"), "w").write(hex16(h))
    print("tables written; FIR coefficient sum =", int(h.sum()), "(32768 = unity gain)")


def make_input(tones, n):
    t = np.arange(n)
    v = sum(a * np.cos(2 * np.pi * f * t / FS) for f, a in tones)
    return np.clip(np.round(2047 * v), -2048, 2047).astype(np.int64)


def model(x):
    ct, st, h = tables()
    n = len(x)
    idx = ((np.arange(n, dtype=np.int64) * INC) & 0xFFFFFFFF) >> 20
    mi = (x * ct[idx]) >> 11
    mq = (x * st[idx]) >> 11
    M = 1 << 33

    def cic(m):
        mp = np.concatenate([[0, 0], m]) % M                       # two clocks of pipeline before the integrators
        s1 = np.concatenate([[0], np.cumsum(mp) % M])
        s2 = np.concatenate([[0], np.cumsum(s1[:-1]) % M])
        s3 = np.concatenate([[0], np.cumsum(s2[:-1]) % M])
        y = s3[49::50]
        c = y
        for _ in range(NCIC):
            c = (c - np.concatenate([[0], c[:-1]])) % M
        c = np.where(c >= M // 2, c - M, c)
        return c >> 17

    def fir(s):
        full = np.convolve(s, h)[:len(s)]
        return full[3::DEC] >> 15

    out = []
    for m in (mi, mq):
        c = cic(m)
        assert np.abs(c).max() < 32768
        y = fir(c)
        assert np.abs(y).max() < 32768
        out.append(y)
    return out[0], out[1]


def run_sim(workdir, x, mut=False):
    """Write in.hex, run the compiled testbench, return the I/Q output arrays."""
    open(os.path.join(workdir, "in.hex"), "w").write("\n".join(f"{int(v) & 0xFFF:03x}" for v in x) + "\n")
    exe = os.path.join(workdir, "obj_mut" if mut else "obj", "Vtb_ddc")
    subprocess.run([exe, f"+n={len(x)}"], cwd=workdir, check=True, stdout=subprocess.DEVNULL)
    rd = lambda f: np.array([int(l) for l in open(os.path.join(workdir, f)).read().split()], dtype=np.int64)
    return rd("out_i.txt"), rd("out_q.txt")


def build(workdir):
    os.makedirs(workdir, exist_ok=True)
    for f in ("nco_cos.mem", "nco_sin.mem", "fir_coef.mem"):
        subprocess.run(["cp", os.path.join(CODE, "rtl", f), workdir], check=True)
    for tag, extra in (("obj", []), ("obj_mut", ["-GCICW=24"])):
        subprocess.run(["verilator", "--binary", "--timing", "-Wno-fatal", "--top-module", "tb_ddc", "-Mdir", os.path.join(workdir, tag), *extra,
                        *[os.path.join(CODE, "rtl", f) for f in ("nco.v", "cic_decim.v", "fir_decim.v", "ddc_top.v")], os.path.join(CODE, "tb", "tb_ddc.v")],
                       check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)


def spectrum(yc, drop=64):
    y = yc[drop:]
    w = np.hanning(len(y))
    sp = np.fft.fftshift(np.fft.fft(y * w))
    fr = np.fft.fftshift(np.fft.fftfreq(len(y), 1 / FOUT))
    return fr, 20 * np.log10(np.abs(sp) / np.abs(sp).max() + 1e-12)


def analyse(yc):
    fr, db = spectrum(yc)
    pk = int(np.argmax(db))
    bw = fr[1] - fr[0]
    near = np.abs(np.arange(len(db)) - pk) <= 12               # skip the window main lobe and its skirts (about ±3.3 kHz)
    spur = db[~near].max()
    k200 = int(np.argmin(np.abs(fr - 200e3)))
    res200 = db[max(k200 - 3, 0):k200 + 4].max()
    return fr[pk], spur, res200


def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else "gen"
    if mode == "gen":
        gen()
        return
    work = os.environ.get("DDC_WORK", os.path.abspath(os.path.join(CODE, "work")))     # build + simulation folder: its path must not contain spaces (Verilator); removed by make clean
    gen()
    build(work)
    lines = []
    # 1) two-tone test: wanted at fc+20 kHz, interferer at fc+700 kHz (same amplitude), bit-exact check against the model
    n = 2048 * 200
    x = make_input([(FC + 20e3, 0.4), (FC + 700e3, 0.4)], n)
    oi, oq = run_sim(work, x)
    mi, mq = model(x)
    k = len(oi)
    bad = int((oi != mi[:k]).sum() + (oq != mq[:k]).sum())
    lines.append(f"DDC bit-exact vs the Python model: {k} output samples (I and Q), {bad} mismatches")
    f0, spur, res = analyse(oi + 1j * oq)
    lines.append(f"DDC two-tone test: wanted tone at fc+20.0 kHz appears at {f0 / 1e3:.1f} kHz; interferer (same amplitude) at fc+700 kHz leaves {res:.1f} dBc at its alias (+200 kHz); worst spur anywhere {spur:.1f} dBc")
    # 2) frequency response: single tones, measured vs the ideal CIC x FIR response
    _, _, h = tables()
    wf, hf = signal.freqz(h / 32768.0, worN=[2 * np.pi * f / 2e6 for f in (10e3, 50e3, 100e3, 150e3, 200e3, 300e3, 400e3, 700e3)])
    offs = (10e3, 50e3, 100e3, 150e3, 200e3, 300e3, 400e3, 700e3)
    amp = 0.4
    ref = None
    for off, hfv in zip(offs, hf):
        x = make_input([(FC + off, amp)], 1024 * 200)
        oi, oq = run_sim(work, x)
        m = np.abs(oi + 1j * oq)[64:]
        meas = np.sqrt((m ** 2).mean())
        cic = abs(np.sin(np.pi * off * R / FS) / (R * np.sin(np.pi * off / FS))) ** NCIC
        ideal = 8 * 2047 * amp * (R ** NCIC / 2 ** 17) * cic * abs(hfv)
        lines.append(f"DDC response at +{off / 1e3:.0f} kHz: measured {20 * np.log10(meas / (8 * 2047 * amp * R ** NCIC / 2 ** 17)):.2f} dB, ideal {20 * np.log10(ideal / (8 * 2047 * amp * R ** NCIC / 2 ** 17)):.2f} dB (relative to the CIC gain at DC)")
    # 3) planted bug: CIC registers too narrow (24 bits instead of 33)
    x = make_input([(FC + 20e3, 0.4), (FC + 700e3, 0.4)], n)
    oi, oq = run_sim(work, x, mut=True)
    k = len(oi)
    bad = int((oi != mi[:k]).sum() + (oq != mq[:k]).sum())
    f0, spur, res = analyse(oi + 1j * oq)
    lines.append(f"DDC bug (CIC registers 24 bits instead of 33): {k} output samples, {bad} mismatches; worst spur {spur:.1f} dBc")
    open(os.path.join(CODE, "reports", "sim_ddc.txt"), "w").write("\n".join(lines) + "\n")
    print("\n".join(lines))


if __name__ == "__main__":
    main()
