---
name: lessons-consolidate
description: Consolidate an accumulated .claude/rules/lessons.md into durable homes (CLAUDE.md rule, path-scoped rule, hook, or deletion) and prune it. Use when lessons.md has grown cluttered, repetitive, or stale.
---

# Consolidate lessons

`lessons.md` is an inbox, not an archive. Periodically each entry either
graduates to a proper home or gets deleted.

## Steps

1. Read the target `lessons.md` in full; group entries by theme.
2. Sort every entry into one bucket:
   - **Graduate - global**: recurred across projects -> propose for
     `~/.claude/CLAUDE.md` (behavior contract) or `~/.claude/rules/`.
   - **Graduate - scoped**: only matters for a file type or subtree -> a
     topic rule with `paths:` frontmatter.
   - **Graduate - enforce**: "must happen at a fixed point" (before commit,
     after edit) -> a hook; prose can then be deleted, not duplicated.
   - **Keep**: still project-specific and still preventing a live mistake.
   - **Delete**: stale, superseded, N=1 that never recurred, or now covered (harness/hooks, or native to the model).
3. Show the proposal as a table (entry -> bucket -> destination) and, for any
   CLAUDE.md change, the edited section in full-document context. Wait for
   consent before writing (contract rule 4).
4. Apply: write destinations first, then rewrite `lessons.md` with only the
   Keep bucket. Nothing may exist in two places - a graduated lesson is
   removed from lessons.md in the same pass.
5. Report counts: graduated / kept / deleted, with file paths touched.
