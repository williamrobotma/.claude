---
name: lesson
description: Write the lesson from a correction to the project's .claude/rules/lessons.md. Use right after the user corrects a mistake, when contract rule 6 says to offer it, or on "write that down" / "/lesson".
---

# Write a lesson

One correction -> one durable rule in the project's `.claude/rules/lessons.md` (create if missing; it auto-loads).

1. State the correction in one line: what was done wrong, what the user said (quote them if specific).
2. Distill to a rule the next session can follow blind: do-form, why on the same line, concrete enough to verify.
3. Read lessons.md first: duplicate -> sharpen the existing entry; contradiction -> replace it, say so.
4. Append under `## <topic>`, one bullet per lesson; show the added lines.

Scope guard (tier per `~/.claude/rules/repo-scoping.md`):
- Project file by default; global (`~/.claude/rules/` or CLAUDE.md) only when justified; ambiguous -> ask.
- File-type or subtree -> a `paths:`-scoped rule.
- One-off fact -> not a lesson; skip and say why.
