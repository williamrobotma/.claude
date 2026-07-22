#!/usr/bin/env python3
"""PostToolUse(Edit|Write) hook: flag non-keyboard glyphs in new .md text.

Enforces the CLAUDE.md Writing rule (basic keyboard symbols only: ->, x, -,
ASCII quotes) deterministically instead of by prompt. Checks only the text
being written (Write content / Edit new_string), so pre-existing prose in a
file never nags. Exit 2 feeds the offending glyphs back for an in-turn fix.
"""
import json
import sys

GLYPHS = {
    "—": "- or ' - '",  # em dash
    "–": "-",           # en dash
    "→": "->",          # right arrow
    "⇒": "=>",          # double right arrow
    "×": "x",           # multiplication sign
    "·": "-",           # middle dot
    "•": "-",           # bullet
    "…": "...",         # ellipsis
    "“": '"',           # left curly double quote
    "”": '"',           # right curly double quote
    "‘": "'",           # left curly single quote
    "’": "'",           # right curly single quote
    " ": " ",           # no-break space
}

try:
    data = json.load(sys.stdin)
except (json.JSONDecodeError, ValueError):
    sys.exit(0)  # unreadable input -> nothing to check

tool_input = data.get("tool_input") or {}
if not tool_input.get("file_path", "").endswith(".md"):
    sys.exit(0)
new_text = tool_input.get("content") or tool_input.get("new_string") or ""
found = [(ch, fix) for ch, fix in GLYPHS.items() if ch in new_text]
if found:
    fixes = "; ".join(f"{ch!r} -> {fix}" for ch, fix in found)
    print("Non-keyboard glyphs in the text just written (CLAUDE.md Writing "
          f"rule: basic keyboard symbols only). Replace: {fixes}",
          file=sys.stderr)
    sys.exit(2)
