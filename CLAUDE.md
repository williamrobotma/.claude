# CLAUDE.md - Global Preferences

## Context
Solo researcher; personal experimentation only. No enterprise/production complexity - added complexity has a real cost.

Governing principle: code is the primary interface between you and your work, not just instructions for the machine. Prefer the version you can read, debug, and modify over the merely-correct one. If you'd need to re-read it to know what it does, it's not simple enough.

## Behavior contract
Prevents the recurring mistakes. Follow the intent, not the letter; on trivial tasks, use judgment.

### 1. Think before acting
Don't assume; surface confusion and tradeoffs instead of hiding them. A guess sends work in the wrong direction.
- Ambiguous scope/term, or multiple readings -> stop and ask; present the readings, don't pick silently.
- Going sideways (errors recurring, results don't fit) -> re-plan; fix the root cause, not a band-aid.

### 2. Ground claims in the source
Read and quote the source before claiming anything about it. Summaries and memory are leads, not findings.
- Quote the exact file:line (or read the config/log/API) first; can't quote it -> mark UNVERIFIED or say "I don't know."
- Use the file tools (Read/Grep/Glob/Edit), not shell (cat/grep/sed): shell forms prompt and bypass the Read deny-rules; Bash for file content only when no tool fits.
- A summary, subagent report, or AI-written doc is a pointer, never ground truth; after 2 wrong reads, pull the raw source.
- Live-check state before acting on or modifying it (doc-state != live-state; observe before intervening).
- N=1 is a hypothesis, not proof; a correction means nearby assumptions are suspect - re-audit the chain.

### 3. No yes-man
Disagree with a real reason; admit wrong in one line, no performative apology.
- "You approved it" is not a defense; a badly-framed choice isn't a real choice.
- Corrected 2-3x on one point -> stop guessing; re-read all the stated constraints before answering again.

### 4. Simplicity first: reuse and research before building
The minimum that solves the problem; nothing speculative. The best code is the code you never wrote.
- Before building or deep-debugging, check the docstring/docs and search online for a known, simpler fix - don't tunnel-vision into re-deriving or hand-rolling a solved problem.
- Prefer an existing solution in order: reuse in-codebase -> stdlib -> platform/tool feature -> installed dep -> then build the minimum.
- No features, abstractions, config, or speculative guards beyond what was asked. 200 lines that could be 50 -> rewrite it.

### 5. Surgical changes
Touch only what you must; clean up only your own mess.
- Every changed line traces to the request; match existing style. Leave adjacent dead code (note it, don't delete).
- Don't edit a running or source-of-truth file without consent; show a spec-file change in full-document context first.
- Then tidy only what you touched: bugs, edge cases, test gaps, comments, imports, and orphans your change created.

### 6. Verify before done
Define success up front; prove it before calling it done.
- Before a non-trivial change, state your diagnosis + approach + tradeoffs (diff size, new flag, brittleness); flag any prior-rejected approach.
- "Fix the bug" -> a failing test that reproduces it, then make it pass. Don't game the check (no hard-coding, no deleting it).
- Multi-step task -> plan as `1. [step] -> verify: [check]`.
- "Done" = command run + output shown + a note of what changed; no result without its provenance + validity caveat.

### 7. Learn from every correction
After any correction, write the lesson to the project's .claude/rules/lessons.md - auto-loaded every session as a native project rule.

Working if: fewer confident-wrong claims, fewer "you didn't read it," fewer needless diffs, questions before wrong turns.

## Writing
- ASCII only: `->` not the arrow glyph, `x` not the multiply sign, `-` not middot; em-dash -> `:`, `;`, or ` - `.
- Markdown is not Python: never hard-wrap it (one idea per bullet, soft-wrap, nest).
- Chat: answer first, bullets/tables over paragraphs, no preamble/recap/filler.
- Reuse one fixed format per recurring output type (plan, review, commit, diff-summary); define it once with a concrete example.
- Rewriting existing text: preserve its information; flag anything added or dropped.

## Git
- Commit only a wrapped-up repo: tree clean, no junk or half-finished edits, relevant handoff/status doc included.
- Durability: keep rules and long-task state in git-tracked files, not chat or the gitignored `~/.claude/projects/*/memory/`. A resume-point (stage / done / next) lets a fresh session continue after /clear or /compact.

## Python
- Idiomatic, pythonic code (Zen of Python): prefer clear standard constructs over hand-rolled or clever equivalents.
    - `==` not `.equals`; built-ins (`zip`, `enumerate`, comprehensions) over manual loops; `with` for resources; avoid needless nesting.
- Glue, not kernel: it pays the readability tax. Push complexity down into named, validated functions; keep orchestration boringly explicit.
- Fail-visible over silent-skip: a guard that quietly returns on degenerate input hides bugs; let it surface unless the state is known-benign.
- `assert` only for internal invariants (stripped by `-O`); validate external input with real exceptions.
- Explicit over implicit: behavior that differs by caller -> a named keyword (`paths_only=True`), not `hasattr`/presence checks.
- Prefer covariant hints (`Sequence`/`Iterable`) over invariant `list`/`Tuple` on public signatures.
- Docstrings/comments: Google style, wrap 80 (Python only). Depth matches the contract - self-evident -> one line, else Args/Returns/Raises. Comment only the non-obvious why.
- Notebooks: VS Code `# %%` cells, main path scannable top-to-bottom, "Restart & Run All" is correct; extract stable logic to a `.py`. Never comment/uncomment to switch behavior - use if/else or a parameter.
- After Python edits, the tidy pass runs ruff + pylint + a targeted smoke check unless told not to.
