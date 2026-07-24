#!/usr/bin/env python3
"""PostToolUse: rumdl check (never --fix) an edited .md; exit 2 = feedback."""
import json
import os
import subprocess
import sys

data = json.load(sys.stdin)
path = data.get("tool_input", {}).get("file_path", "")
if not path.endswith(".md"):
    sys.exit(0)

rumdl = os.path.expanduser("~/.local/bin/rumdl")
r = subprocess.run([rumdl, "check", path], capture_output=True, text=True)
if r.returncode == 0:
    sys.exit(0)

print(r.stdout, file=sys.stderr)
print(
    ">120 cols means rewrite, not reflow: cut redundancy, or split multi-idea"
    " lines into sub-bullets. Never split a single idea to pass the check, and"
    " write full sentences - splitting is not swapping in semicolons."
    " A line that must be long may stand - say why and move on.",
    file=sys.stderr,
)
sys.exit(2)
