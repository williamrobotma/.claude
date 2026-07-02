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
- A per-machine override exists (`ANTHROPIC_MODEL` / `CLAUDE_CODE_EFFORT_LEVEL` in
  that machine's own shell profile, e.g. `~/.bashrc`, outside this repo) but it is
  NOT a clean substitute for a local settings file: per the official docs
  (https://code.claude.com/docs/en/model-config#adjust-effort-level), "the
  environment variable takes precedence over all other methods" - i.e. it beats
  `/effort`/`/model` too, not just the `settings.json` default, so `/effort`
  becomes inert for the rest of any session on that machine. Reserve this for a
  machine that should never interactively change effort/model; otherwise just
  accept one shared value in `settings.json` (edit it directly if `/effort`'s
  "save as default" would conflict with another machine's choice).
