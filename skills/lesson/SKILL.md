---
name: lesson
description: Write the lesson from a correction to the project's .claude/rules/lessons.md. Use right after the user corrects a mistake, when contract rule 6 says to offer it, or when the user says "write that down" / "/lesson".
---

# Write a lesson

Turn the correction that just happened into one durable, auto-loaded rule in
the *project's* `.claude/rules/lessons.md` (create the file if missing; it
loads every session as a native project rule).

## Steps

1. State the correction in one line: what was done wrong, what the user said
   instead. Quote the user's actual words if they were specific.
2. Distill it to a rule the next session can follow blind:
   - The do-form, not just the don't (name the replacement behavior).
   - Include the why in the same line - that's what makes it generalize.
   - Concrete enough to verify; no vague "be careful with X".
3. Read the existing `lessons.md` first:
   - Same lesson already there -> sharpen that entry instead of appending a
     duplicate.
   - Contradicting entry -> replace it and say so; don't leave both.
4. Append under a `## <topic>` heading, one bullet per lesson.
5. Show the added/changed lines; if the tree matters to the user, remind them
   it's uncommitted.

## Scope guard

- Global habit (applies in every project) -> it belongs in `~/.claude/CLAUDE.md`
  or `~/.claude/rules/`; say so instead of burying it in one project.
- File-type-specific -> suggest `paths:` frontmatter in a topic rule rather
  than lessons.md.
- One-off fact of this conversation -> not a lesson; skip and say why.
