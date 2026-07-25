---
paths:
  - "**/.claude/settings.json"
  - "**/.claude/settings.local.json"
---

# Settings scope: `~/.claude/settings.local.json` is home-rooted project-local

Claude Code has no user-*scope* `settings.local.json` - but that is a statement about scope, not the path. In a session whose project root is the home directory (cwd = `~`), `<project>/.claude/settings.local.json` resolves to exactly `~/.claude/settings.local.json`, which loads as *project-local* settings (precedence: Local > Project > User); the always-allow flow also writes new grants there.

- Grants in that file are live only in home-rooted sessions; a grant meant for every project must be hoisted into `settings.json`.
- Deleting the file is futile - the next always-allow click in a home-rooted session regenerates it. Leave it untracked (the `.gitignore` catch-all covers it); periodically hoist the portable grants into `settings.json` and drop the crumbs.
- `/model` and `/effort` "save as default" always write to the tracked, synced
  `~/.claude/settings.json` - there is no unsynced *file* to keep a model/effort
  choice per machine.
- model/effort values used to collide on every sync. Fix: `.gitattributes` routes
  settings.json through `merge-settings.py` (a merge driver registered in
  `sync.sh`). If the only differing keys are per-machine prefs it keeps this
  machine's copy; if anything else differs it falls back to git's normal merge, so
  a real change (a permission, a plugin) still surfaces as a visible conflict and
  is never silently dropped. Net: those prefs are effectively per-machine and
  `/model`/`/effort` keep working everywhere.
  - PER_MACHINE (`merge-settings.py`): `model`, `effortLevel`, `tui`, `advisorModel`,
    `askUserQuestionTimeout`, `theme`, `verbose`. `editorMode` is NOT per-machine (it merges).
  - The driver neutralizes these keys even in the fallback path (rewrites the incoming
    per-machine lines to match ours), so they never conflict just because a real key changed
    alongside them. A settings.json conflict that survives is therefore a genuine real-key
    clash (or a gap in this set) - hand-resolve the real key; if a per-machine pref conflicted,
    the set has a gap - add it here.
- Not used: the `ANTHROPIC_MODEL` / `CLAUDE_CODE_EFFORT_LEVEL` env vars would also
  pin model/effort per-machine, but per the docs they beat interactive
  `/model`/`/effort` too, making those commands inert - the merge driver does not.
