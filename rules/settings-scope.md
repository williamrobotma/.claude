---
paths:
  - "**/settings.json"
  - "**/settings.local.json"
---

# Settings scope: no user-level `settings.local.json`

Claude Code's "Local" settings scope is `.claude/settings.local.json` inside a
*project*, not `~/.claude/`. There is no unsynced, machine-local settings file
at the user level.

- `/model` and `/effort` "save as default" always write to the tracked, synced
  `~/.claude/settings.json` - there is no unsynced *file* to keep a model/effort
  choice per machine.
- A file at `~/.claude/settings.local.json` is never read by Claude Code. If
  one exists, migrate any real content (e.g. permissions) into `settings.json`
  and delete it.
- model/effort values used to collide on every sync. Fix: `.gitattributes` routes
  settings.json through `merge-settings.py` (a merge driver registered in
  `sync.sh`). If the only differing keys are per-machine prefs it keeps this
  machine's copy; if anything else differs it falls back to git's normal merge, so
  a real change (a permission, a plugin) still surfaces as a visible conflict and
  is never silently dropped. Net: those prefs are effectively per-machine and
  `/model`/`/effort` keep working everywhere.
  - PER_MACHINE (`merge-settings.py`): `model`, `effortLevel`, `tui`, `advisorModel`,
    `askUserQuestionTimeout`, `theme`, `verbose`. `editorMode` is NOT per-machine (it merges).
  - A settings.json conflict means this set has a gap (a per-machine pref missing) - fix the set, don't hand-resolve.
- Not used: the `ANTHROPIC_MODEL` / `CLAUDE_CODE_EFFORT_LEVEL` env vars would also
  pin model/effort per-machine, but per the docs they beat interactive
  `/model`/`/effort` too, making those commands inert - the merge driver does not.
