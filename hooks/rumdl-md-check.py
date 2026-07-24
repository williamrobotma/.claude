#!/usr/bin/env python3
"""PostToolUse: rumdl MD013 on an edited .md, scoped to added lines."""
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
r = subprocess.run([rumdl, "check", "-e", "MD013", path], capture_output=True, text=True)
if r.returncode == 0:
    sys.exit(0)

# Scope to lines this edit introduced: keep a hit only if that file line's text
# was part of new_string / content. No git, no line arithmetic; an added line
# identical to one elsewhere over-reports, which is harmless.
changed = ti.get("new_string", ti.get("content"))
if changed is not None:
    added = set(changed.splitlines())
    with open(path, encoding="utf-8") as f:
        lines = f.read().splitlines()
    kept = []
    for out in r.stdout.splitlines():
        if not out.startswith(path + ":"):
            continue
        try:
            n = int(out[len(path) + 1:].split(":", 1)[0])
        except ValueError:
            continue
        if 1 <= n <= len(lines) and lines[n - 1] in added:
            kept.append(out)
    if not kept:
        sys.exit(0)
    report = "\n".join(kept)
else:
    report = r.stdout  # unexpected tool_input shape -> report all, don't skip silently

print(report, file=sys.stderr)
print(
    ">120 cols means rewrite, not reflow: cut redundancy, or split multi-idea"
    " lines into sub-bullets. Never split a single idea to pass the check, and"
    " write full sentences - splitting is not swapping in semicolons."
    " A line that must be long may stand - say why and move on.",
    file=sys.stderr,
)
sys.exit(2)
