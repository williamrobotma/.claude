---
name: pr-review-sweep
description: Use when the user wants a PR (or branch changes) reviewed from several independent angles before merge - e.g. "open a PR and review it", "spawn reviews on this PR", "get this reviewed from all angles", "run /review and /simplify and security-review on my changes". Not for a single quick self-review.
---

# PR review sweep

Fan out several independent, report-only reviews on a PR, vet what they find, then apply only what the user approves.

## Core discipline

- Reviews are report-only: no edits, no commits, no PR comments - run each reviewer in an isolated git worktree so it cannot touch the tree.
- Subagent findings are pointers, not truth: re-check every one against the real diff, and get the user's approval before changing anything.

## Steps

1. Land the PR: branch off the default branch if needed, commit, push, `gh pr create`; target an existing PR if there is one.
2. Pick lenses to fit the diff. Default set: `/review`, `/simplify` (report-only), `security-review`, `auditing-permission-scope`.
3. Add any lens the diff warrants; for a lens with no real surface, run it anyway and record the null - never skip silently.
4. Fan out in parallel: one subagent per lens, each in its own worktree, each told "no edits, findings only", each given the same PR context and a fixed return format.
5. Vet every finding against the diff: confirm it cites a real `file:line` and reproduces; drop the hallucinated or out-of-scope ones.
6. Report once: severity-ranked findings, fixes grouped must-fix / optional / nit, plus what came back clean.
7. Confirm before touching anything: let the user pick which tiers to apply.
8. Apply approved fixes to the same PR branch, re-run the repo's lint/link/test gates, then push.
9. Merge only on explicit say-so, after re-checking mergeable + gates green, using the repo's merge style.

## Reviewer return format

- One-line verdict.
- Findings, worst first: `[sev] file:line - issue -> fix (in-scope: y/n)`.
- "No issues for this lens" when clean.

## Common mistakes

- Applying fixes before the user signs off - the findings are unvetted.
- Letting `/simplify` auto-apply; it edits by default, so force report-only and keep worktree isolation as the backstop.
- Relaying or acting on a finding you have not reproduced against the diff.
- Marking a lens "not applicable" instead of running it and recording the null.
