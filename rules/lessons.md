# Lessons (global)

Corrections distilled into rules; consolidate periodically with /lessons-consolidate.

## Agent and workflow spawning

- Price every spawn before launch: state max agents x model tier. (2026-07-28)
  - Gate on an explicit go when it exceeds the session guideline or runs at opus tier or above.
  - Packaged/named workflows are not pre-approved: read the script - fan-out and model inheritance are invisible.
  - Exception: a skill whose text states its default price (count x tier) is pre-approved at that price.
  - Pin per-stage models (search -> haiku, verify -> sonnet, synthesis -> inline) and set a token budget.
  - Unpinned stages inherit the session model, so the whole script runs at the priciest tier.
  - Why: a named deep-research workflow spawned 103 agents on the session model and burned the session limit.

## Grounding claims

- Cite the exact line verbatim at claim time: the scope qualifier is part of the claim. (2026-07-28)
  - A paraphrase is where the qualifier drops.
  - Why: "everything Ollama-side stays frozen" paraphrased to "all deletion is deferred" silently widened a spec rule.
- The revision a line was read at, and the policy doc defining its terms, are scope qualifiers too. (2026-08-07)
  - Why: called a moved build a broken pin; the repo's pins-move-forward policy was already in my grep output.
- Sweep for a deleted artifact under every name form it had (path, id, basename). (2026-08-07)
  - Why: searched deleted Modelfiles by path only; a reviewer found 8 stale README rows by model id.
- Absence is a claim: prove it over the whole search space, never from a truncated or narrowed search. (2026-08-09)
  - No `| head` on a grep meant to show something is missing - count matches tree-wide, then quote the zero.
  - To test that a switch turned X off, look for X's own marker to disappear; a nearby metric sharing vocabulary lies.
  - Why: `grep ... | head -8` filled with near-miss hits, so "the env var was removed upstream" shipped to git; the var
    was one match further down, and the counter read as proof was a different subsystem's.
- An activity claim needs an activity source (logged runs/requests), cited at claim time. (2026-08-08)
  - Elapsed calendar time is not activity; a plan's future-tense phrase is not a record; X's result is not Y's.
  - A recorded caveat is never "outweighed" by an uncited claim: override with a source, or not at all.
  - Pressure test: the moment a claim justifies the recommendation you already prefer, re-derive it from sources.
  - Why: "weeks of crash-free mileage" fused a spec phrase + a date span + another model's clean run, and was
    asserted over the correct caveat sitting 8 lines above it in the same file.
- Verify against the artifact the user will actually run, not a simpler stand-in. (2026-08-10)
  - A synthetic probe can pass for reasons the real input does not share; name the artifact tested in the claim.
  - Why: a bare `numpy` solve "proved" conda-forge-only while `environment.yml` pulled 2019 scanpy from bioconda.

## Writing

- Scan test, notation consistency, and right-sizing were folded straight into the CLAUDE.md Writing section. (2026-07-29)
  - Why: one GitHub-issue draft took four revision rounds before its structure, consistency, and length were acceptable.

## Execution sessions

- In an execution session, a discovered smell becomes one crisp decision question; then keep executing. (2026-07-28)
  - Research only to answer a question the user actually asked; report findings, then return to the list.
  - Never present options that reopen settled decisions unless the user asks to reopen them.
  - Why: mid-implementation investigation of locked choices derailed a run-spec session into a revert and restart.

## Probing live state

- A command run to demonstrate a failure still executes: prove it on a scratch copy, not the live file. (2026-08-10)
  - "It will just error" is a prediction, not a property - a tool may happily delete a key it cannot otherwise read.
  - Scratch copies are cheap: `--rc-file`, a temp root prefix, a `CONDARC=`-style override, a copied file.
  - Why: a probe meant to show conda could not touch `mirrored_channels` silently deleted it from the live `.condarc`.
