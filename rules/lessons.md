# Lessons (global)

Corrections distilled into rules; consolidate periodically with /lessons-consolidate.

## Agent and workflow spawning

- Price every spawn before launch: state max agents x model tier. (2026-07-28)
  - Gate on an explicit go when it exceeds the session guideline or runs at opus tier or above.
  - Packaged/named workflows are not pre-approved: read the script - fan-out and model inheritance are invisible.
  - Pin per-stage models (search -> haiku, verify -> sonnet, synthesis -> inline) and set a token budget.
  - Unpinned stages inherit the session model, so the whole script runs at the priciest tier.
  - Why: a named deep-research workflow spawned 103 agents on the session model and burned the session limit.

## Grounding claims

- Cite the exact line verbatim at claim time: the scope qualifier is part of the claim. (2026-07-28)
  - A paraphrase is where the qualifier drops.
  - Why: "everything Ollama-side stays frozen" paraphrased to "all deletion is deferred" silently widened a spec rule.

## Writing

- Scan test, notation consistency, and right-sizing were folded straight into the CLAUDE.md Writing section. (2026-07-29)
  - Why: one GitHub-issue draft took four revision rounds before its structure, consistency, and length were acceptable.

## Execution sessions

- In an execution session, a discovered smell becomes one crisp decision question; then keep executing. (2026-07-28)
  - Research only to answer a question the user actually asked; report findings, then return to the list.
  - Never present options that reopen settled decisions unless the user asks to reopen them.
  - Why: mid-implementation investigation of locked choices derailed a run-spec session into a revert and restart.
