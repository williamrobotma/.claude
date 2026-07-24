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

# Nag only about lines this edit added: keep a warning whose file line was in
# new_string / content. Match on line text, not path (rumdl prints a relative
# path); rumdl -e MD013 keeps the code-block / table exemptions a len() check
# would lose.
added = set((ti.get("new_string") or ti.get("content") or "").splitlines())
with open(path, encoding="utf-8") as f:
    lines = f.read().splitlines()
hits = [w for w in json.loads(r.stdout) if lines[w["line"] - 1] in added]
if not hits:
    sys.exit(0)

for w in hits:
    print(f"{path}:{w['line']}:{w['column']}: {w['message']}", file=sys.stderr)
print(
    ">120 cols means rewrite, not reflow: cut redundancy, or split multi-idea"
    " lines into sub-bullets. Never split a single idea to pass the check, and"
    " write full sentences - splitting is not swapping in semicolons."
    " A line that must be long may stand - say why and move on.",
    file=sys.stderr,
)
sys.exit(2)
