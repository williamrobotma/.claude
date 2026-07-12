#!/usr/bin/env python3
"""PostToolUse(Edit|Write) hook: ruff-check any edited .py file.

Exit 2 feeds the findings back to Claude so the fix happens in-turn
(the task-end-tidy contract rule, enforced instead of remembered).
Non-.py files and clean files fall through silently; a missing ruff
fails loudly with a traceback rather than being masked.
"""
import json
import subprocess
import sys

try:
    data = json.load(sys.stdin)
except (json.JSONDecodeError, ValueError):
    sys.exit(0)  # unreadable input -> nothing to check

path = (data.get("tool_input") or {}).get("file_path", "")
if not path.endswith(".py"):
    sys.exit(0)

result = subprocess.run(
    ["ruff", "check", "--output-format", "concise", path],
    capture_output=True, text=True,
)
if result.returncode:
    print(result.stdout + result.stderr, file=sys.stderr)
    sys.exit(2)
