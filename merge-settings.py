#!/usr/bin/env python3
"""settings.json merge driver: if the only keys that differ are per-machine
(model, effortLevel), keep ours; otherwise fall back to git's normal 3-way
merge. Registered per-clone by sync.sh. Called as: merge-settings.py %O %A %B.
"""

import json
import subprocess
import sys

PER_MACHINE = {"model", "effortLevel"}


def load(path):
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def main():
    base, ours, theirs = sys.argv[1], sys.argv[2], sys.argv[3]
    a = load(ours)
    b = load(theirs)
    changed = {k for k in set(a) | set(b) if a.get(k) != b.get(k)}
    if changed <= PER_MACHINE:
        return  # ours (%A) already holds this machine's values; keep it
    sys.exit(subprocess.call(["git", "merge-file", ours, base, theirs]))


if __name__ == "__main__":
    main()
