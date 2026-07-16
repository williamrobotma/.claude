#!/usr/bin/env python3
"""settings.json merge driver: if the only keys that differ are per-machine
preferences, keep ours; otherwise fall back to git's normal 3-way merge (which
unions shared additions like permissions line-by-line). Before that fallback,
rewrite theirs' per-machine key lines to match ours, so those prefs never turn
into a hand-resolved conflict just because a real key changed alongside them.
Registered per-clone by sync.sh. Called as: merge-settings.py %O %A %B.
"""

import json
import re
import subprocess
import sys

# Per-machine preferences: kept as this clone's value, never merged. Everything
# else (permissions, plugins, hooks, env, ...) falls through to a normal merge.
PER_MACHINE = {
    "model",
    "effortLevel",
    "tui",
    "advisorModel",
    "askUserQuestionTimeout",
    "theme",
    "verbose",
}


def load(path):
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def neutralize(ours, theirs, keys):
    """Return theirs' text with each `keys` line replaced by ours' line.

    settings.json is pretty-printed one key per line, and these keys always sit
    mid-object (trailing comma), so a whole-line swap keeps it valid. When both
    sides then agree on those lines, git merge-file emits no conflict there. The
    regex anchors to the top-level two-space indent, so a same-named nested key
    (e.g. a plugin's own "model") can never be matched and clobbered.
    """
    with open(ours, encoding="utf-8") as f:
        our_lines = f.readlines()
    with open(theirs, encoding="utf-8") as f:
        their_lines = f.readlines()
    for key in keys:
        pat = re.compile(r'^  "' + re.escape(key) + r'"\s*:')
        our_line = next((line for line in our_lines if pat.match(line)), None)
        if our_line is None:
            continue  # key absent in ours (structural); let merge-file handle it
        their_lines = [our_line if pat.match(line) else line for line in their_lines]
    return "".join(their_lines)


def main():
    base, ours, theirs = sys.argv[1], sys.argv[2], sys.argv[3]
    a = load(ours)
    b = load(theirs)
    changed = {k for k in set(a) | set(b) if a.get(k) != b.get(k)}
    if changed <= PER_MACHINE:
        return  # ours (%A) already holds this machine's values; keep it

    # A real key changed too: 3-way text merge, but first neutralize the
    # per-machine keys so they don't produce spurious conflicts. theirs (%B) is
    # git's throwaway scratch copy and neutralize has already read it, so write
    # the patched text back over it and hand that to merge-file.
    patched = neutralize(ours, theirs, PER_MACHINE & changed)
    with open(theirs, "w", encoding="utf-8") as f:
        f.write(patched)
    sys.exit(subprocess.call(["git", "merge-file", ours, base, theirs]))


if __name__ == "__main__":
    main()
