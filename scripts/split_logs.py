#!/usr/bin/env python3
"""OpenETL's chunker does not split a log: one 5 MB Apache.log came out as two chunks of 1.7 MB and 3.4 MB
(no sentence/paragraph breaks to split on). So cut each big downloaded log into parts of N lines (default 40, about
one chunk's worth) under downloads/logs-parts/<name>/. Lines are copied verbatim; nothing is edited or invented.
usage: split_logs.py [lines_per_part] [max_lines_per_log]"""
import sys, shutil
from pathlib import Path
root = Path(__file__).resolve().parent.parent / "downloads"
per = int(sys.argv[1]) if len(sys.argv) > 1 else 40
cap = int(sys.argv[2]) if len(sys.argv) > 2 else 10**9
out = root / "logs-parts"; shutil.rmtree(out, ignore_errors=True)
for name in ("Apache", "SSH", "Linux", "HealthApp"):
    src = root / "logs" / name / f"{name}.log"
    if not src.exists(): continue
    d = out / name; d.mkdir(parents=True)
    n = part = 0; buf = []
    with src.open(errors="replace") as f:
        for line in f:
            buf.append(line); n += 1
            if len(buf) == per:
                (d / f"{name}-{part:06d}.log").write_text("".join(buf)); part += 1; buf = []
            if n >= cap: break
    if buf: (d / f"{name}-{part:06d}.log").write_text("".join(buf)); part += 1
    print(f"{name}: {n} lines -> {part} parts")
