---
name: lessons-consolidate
description: Fold each lessons.md entry into its durable home - repo AGENTS.md/CLAUDE.md by default - or delete it. Use when lessons.md accumulates.
---

# Consolidate lessons

lessons.md is an inbox, not an archive. Every entry ends in exactly one home.

1. Read the target lessons.md in full.
2. Bucket each entry:
   - **Project** (default): -> the repo's AGENTS.md/CLAUDE.md, in the section it belongs to.
   - **Global**: justified every-project -> `~/.claude/CLAUDE.md` or `~/.claude/rules/`; ambiguous -> ask.
   - **Scoped**: one file type or subtree -> a rule with `paths:` frontmatter.
   - **Enforce**: fires at a fixed point (pre-commit, post-edit) -> a hook; the prose is then deleted.
   - **Keep**: too fresh to place, still preventing a live mistake.
   - **Delete**: stale, superseded, never recurred, now enforced elsewhere, or native to served models.
3. Propose scannably - table (entry -> bucket -> destination) + exact new lines at anchors; no rationale prose.
4. On consent: write destinations, then rewrite lessons.md with only Keep; delete the file if empty.
5. Report: graduated / kept / deleted, files touched.
