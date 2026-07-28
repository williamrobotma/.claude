---
name: delegation
description: Use before spawning any subagent or workflow - decides whether to spawn at all and which model each task gets.
---

# Delegation

**Match the model to how hard a mistake is to catch: cheap when wrong answers are obvious, frontier when they look right.**

1. A quick check - a grep, a count, one file read - do it inline. No agent.
2. Otherwise, per task:
   - haiku: search - find a file, grep a pattern, fetch a page. Wrong answers are obviously wrong.
   - sonnet: mechanical edits and fact-checking - rename sweeps, a known fix, a lookup you'll verify at the source.
   - opus or better: review and judgment calls - code review, design decisions, style. Wrong answers look right.
   - fable (2x opus): sign-off - the last review before a decision. In a fable session, all review runs on fable.
3. Mixed task: split it - the search goes to haiku, the verdict on what it found goes to opus.
4. Workflows multiply the decision: price the launch first - max agents x model tier, stated before
   the call - and get an explicit go above the session size guideline or at opus tier or above.
   - Named/packaged workflows are not pre-approved: read the script; fan-out and model inheritance
     are invisible from the name.
   - Pin per-stage models in the script (search -> haiku, fetch/verify -> sonnet, synthesis -> inline
     in the main loop) and set a token budget; agents inherit the session model, so an unpinned
     script runs every stage at the priciest tier.
