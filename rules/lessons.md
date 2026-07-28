# Lessons (global)

Corrections distilled into rules; consolidate periodically with /lessons-consolidate.

## Agent and workflow spawning

- Price every spawn before launch - state max agents x model tier - and gate on explicit go when it exceeds the
  session guideline or runs at opus tier or above. (2026-07-28)
  - Packaged/named workflows are not pre-approved: read the script first; fan-out and model inheritance are
    invisible from the name.
  - Pin per-stage models before launching (search -> haiku, fetch/verify -> sonnet, synthesis -> inline in the
    main loop) and set a token budget; agents inherit the session model, so an unpinned script runs every stage
    at the priciest tier.
  - Why: a named deep-research workflow spawned 103 agents, all on the session model, and burned the session
    limit mid-run.

## Grounding claims

- Cite the exact line verbatim at claim time; the scope qualifier is part of the claim, and a paraphrase is where
  it gets dropped. (2026-07-28)
  - Why: "everything Ollama-side stays frozen" paraphrased to "all deletion is deferred" silently widened a
    spec rule and misdirected planning until the user challenged it.

## Execution sessions

- In an execution session, a discovered smell becomes one crisp decision question to the user; then keep
  executing the task list. (2026-07-28)
  - Research only to answer a question the user actually asked; report findings, then return to the list.
  - Never present options that reopen settled decisions unless the user asks to reopen them.
  - Why: mid-implementation investigation of already-locked choices derailed a run-spec session into a full
    revert and restart.
