---
paths:
  - "**/.claude/**"
---

# Scope ~/.claude repo-specific instructions properly

`~/.claude/CLAUDE.md` is loaded into *every* session, in every project, since
it doubles as the always-on user-level instructions file. Anything that only
matters when working on this config repo itself (settings.json internals,
sync.sh, hooks, skills, rules mechanics, etc.) does not belong there - it would
add noise to unrelated project sessions.

- Put repo-specific facts/rules in a topic file under `~/.claude/rules/` with
  a `paths` frontmatter glob (e.g. matching `**/settings.json` or
  `**/.claude/**`) so it only loads when Claude is actually touching the
  relevant files.
- Reserve `~/.claude/CLAUDE.md` for preferences that should apply to every
  project regardless of what's being worked on.
- When adding a new fact about how this repo works, ask: "would this be
  useful noise in a session about an unrelated project?" If yes, it's
  path-scoped; if no, it's global.
- This only covers content meant to sync across machines. For something that
  must never appear on another machine at all (not even as a reference in a
  tracked file), use `~/.claude/CLAUDE.local.md` instead - see README.md
  "Machine-local instructions". Rules/hooks/settings.json have no genuinely
  local-only mode; anything there is either tracked everywhere or requires a
  tracked reference to ever load.
