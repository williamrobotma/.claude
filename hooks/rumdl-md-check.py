#!/usr/bin/env python3
"""PostToolUse: rumdl MD013 on an edited .md, scoped to added lines.

Exit 2 (feedback on stderr) when a line this edit added exceeds 120 cols.
"""
import json
import os
import subprocess
import sys

data = json.load(sys.stdin)
ti = data.get("tool_input", {})
path = ti.get("file_path", "")
if not path.endswith(".md"):
    sys.exit(0)

rumdl = os.path.expanduser("~/.local/bin/rumdl")
r = subprocess.run(
    [rumdl, "check", "-e", "MD013", "--output-format", "json", path],
    capture_output=True, text=True,
)
if r.returncode == 0:
    sys.exit(0)

try:
    warnings = json.loads(r.stdout)
except json.JSONDecodeError:
    warnings = None  # unexpected output -> fail loud below, don't skip silently

# Scope to lines this edit introduced: keep a warning only if that file line's
# text was part of new_string / content. A line the edit didn't touch is not
# ours to nag about. A dup of a line elsewhere over-reports, which is harmless.
changed = ti.get("new_string", ti.get("content"))
if warnings is not None and changed is not None:
    added = set(changed.splitlines())
    with open(path, encoding="utf-8") as f:
        lines = f.read().splitlines()
    kept = []
    for w in warnings:
        n = w["line"]
        if 1 <= n <= len(lines) and lines[n - 1] in added:
            kept.append(f"{path}:{n}:{w['column']}: {w['message']}")
    if not kept:
        sys.exit(0)
    report = "\n".join(kept)
else:
    report = r.stdout + r.stderr  # unexpected shape -> report all, don't skip

print(report, file=sys.stderr)
print(
    ">120 cols means rewrite, not reflow: cut redundancy, or split multi-idea"
    " lines into sub-bullets. Never split a single idea to pass the check, and"
    " write full sentences - splitting is not swapping in semicolons."
    " A line that must be long may stand - say why and move on.",
    file=sys.stderr,
)
sys.exit(2)
