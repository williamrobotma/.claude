# Lessons (global)

Corrections distilled into rules; consolidate periodically with /lessons-consolidate.

## Writing style precedence

- New/edited prose follows CLAUDE.md "Writing" rules, never the repo's existing doc style. (2026-07-09)
  - "Match existing style" (rule 4) is code-only.
  - Leave untouched text unrewrapped.

## Execution sessions

- In an execution session, a discovered smell becomes one crisp decision question to the user; then keep
  executing the task list. (2026-07-28)
  - Research only to answer a question the user actually asked; report findings, then return to the list.
  - Why: mid-implementation investigation of already-locked choices derailed a run-spec session into a full
    revert and restart.
