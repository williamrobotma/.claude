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
  `~/.claude/settings.json` - there is no native way to keep a model/effort
  choice unsynced per machine.
- A file at `~/.claude/settings.local.json` is never read by Claude Code. If
  one exists, migrate any real content (e.g. permissions) into `settings.json`
  and delete it.
