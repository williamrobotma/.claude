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
failed = r.returncode != 0

if failed:
    print(r.stdout, file=sys.stderr)
    print(
        ">120 cols means rewrite, not reflow: cut redundancy, or split"
        " multi-idea lines into sub-bullets. NEVER fix length by breaking a"
        " line mid-idea - a wrapped continuation is itself a violation (this"
        " hook detects it). Never split a single idea to pass the check; a"
        " line that must be long may stand - say why and move on.",
        file=sys.stderr,
    )


def line_kind(s):
    if not s:
        return "blank"
    if s[0] in "-*+":
        return "list"
    if s[0].isdigit():
        i = 0
        while i < len(s) and s[i].isdigit():
            i += 1
        if i < len(s) and s[i] in ".)":
            return "list"
    if s[0] in "#>|<":
        return "struct"
    return "content"


if "docs/history/" not in path and "specs/done/" not in path:
    with open(path) as f:
        lines = f.read().splitlines()
    in_fence = False
    in_front = bool(lines) and lines[0].strip() == "---"
    prev = None
    flags = []
    for i, raw in enumerate(lines, 1):
        s = raw.strip()
        if in_front:
            if i > 1 and s in ("---", "..."):
                in_front = False
            prev = None
            continue
        if s.startswith("```") or s.startswith("~~~"):
            in_fence = not in_fence
            prev = None
            continue
        if in_fence:
            prev = None
            continue
        kind = line_kind(s)
        if (
            prev
            and prev[1] in ("content", "list")
            and kind == "content"
            and (("a" <= s[0] <= "z") or prev[0].endswith((",", ";")))
        ):
            flags.append(i)
        prev = (s, kind)

    if flags:
        for ln in flags:
            print(
                f"{path}:{ln}: hard-wrap - line continues the previous"
                " idea; join into one line (or split into real"
                " sub-bullets)",
                file=sys.stderr,
            )
        print(
            "Markdown is soft-wrap only: a mid-idea line break is itself"
            " the violation, even when it makes lines shorter.",
            file=sys.stderr,
        )
        failed = True

sys.exit(2 if failed else 0)
