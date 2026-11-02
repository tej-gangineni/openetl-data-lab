#!/usr/bin/env python3
"""A downloaded JSON file is one array of hundreds of objects, and OpenETL turns that into a handful of text chunks,
not one record per object. So write each array element to its own file under downloads/json-items/<name>/.
Each file is the verbatim element; nothing is edited or invented."""
import json, shutil
from pathlib import Path
root = Path(__file__).resolve().parent.parent / "downloads"
out = root / "json-items"; shutil.rmtree(out, ignore_errors=True)
for f in sorted((root / "json").glob("*/*.json")):
    items = json.loads(f.read_text()); d = out / f.parent.name; d.mkdir(parents=True)
    for i, it in enumerate(items):
        (d / f"{f.parent.name}-{i:05d}.json").write_text(json.dumps(it, ensure_ascii=False, indent=1))
    print(f"{f.parent.name}: {len(items)} objects -> {len(items)} files")
