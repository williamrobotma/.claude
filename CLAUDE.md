# CLAUDE.md — Global Preferences
## Context
Solo researcher; personal experimentation only. No enterprise/production complexity. All added complexity has a real cost.

**Governing principle: code is not just for the machine — it is the primary interface between the user and their own work. Prefer the implementation the user can read, debug, and modify without friction over the one that is merely correct. If the user would need to re-read it to understand what it does, it is not simple enough.**

## Core Behavior
- Only do what is asked; no unrequested changes or features.
- Ask for clarification when ambiguous; never guess.
- "Over-engineered" applies to behavior too — if it needs layered rules to explain, simplify the behavior first.
- Don't add filtering, sanitizing, or pruning unless asked or clearly required for correctness.
- Don't edit currently running files without explicit approval.
- After edits, run a quick verification.
- When revising an artifact the user has signaled is "mostly good" (a plan, doc, or code file), produce minimal targeted edits — not a parallel rewrite. Quote the specific lines/sections being changed and the replacement text; don't restate unchanged scaffolding.
- When making multiple changes, present them as discrete labeled units — not interleaved in a wall of output. Each unit: what changed, where, and one-line why. Unrelated changes get separate units even if delivered together.
- Don't mix structural changes with style/cleanup changes in the same edit. Flag cleanup separately so the user can accept or skip it without untangling it from logic changes.

## Tidy+Review Pass
Unless narrowed or opted out, finish code-editing tasks with a pass over touched code: check for bugs, regressions, edge cases, and test gaps; fix comments, docstrings, formatting, and imports; note streamlining opportunities. Scope: current uncommitted changes and/or current session, whichever is broader.

After refactoring: scan for dead assignments and orphaned functions left over from the previous structure — variables initialized but never read, wrapper functions that exist solely to forward to one other call.

## Shell Discipline
- Prefer workspace-relative paths; use absolute only when a tool requires it.
- Use bare binary names (ruff, pylint, etc.); rely on PATH or the active venv.

---

## Python

### Design
- When choosing between two approaches that both work, prefer the one the user can scan and modify confidently. Cleverness that saves lines but costs comprehension is a net loss.
- Least complex solution that works; simple, explicit control flow over layered machinery.
- No speculative guards, validation, or branching; add only for real invariants or actual failures.
- Main path scannable top-to-bottom. Definitions near use. Inline single-use helpers; extract only genuinely reused or dense logic.
- Prefer the clearest standard construct over clever convenience helpers or hand-rolled machinery when both do the same job. Use `==` over `.equals()` or `.eq()`, use for loops and comprehensions over `map` and `filter`, use slicing and built-ins like `zip`, `enumerate`, `sorted`, `reversed`, `any`, `all`, `sum`, `min`, `max`, `len`, etc. over custom helpers that do the same thing.
- joblib.Parallel job wrapper functions must be ≤3 lines (name, call, return). If longer, restructure the called function instead.
- For multi-axis iteration, prefer `itertools.product` over triple-nested list comprehensions.
- Use `with` statements for all resource management (files, connections, locks). Never open without a context manager.
- When there is one obvious, standard way to do something, use it. Don't reach for a custom solution when a built-in idiom exists.
- Explicit over implicit: code should show what it does, not hide it behind abstraction, magic, or indirection.
- When multiple callables share a dispatch pattern (name → fn + fixed kwargs), encode as a `dict[str, Callable]` using `functools.partial` to pre-bind kwargs — not as `(name, fn, kwargs)` tuples passed around.

### Style
- PEP 8 and PEP 257 unless the repo deviates.
- Prefer the form that reads closest to plain English. If a fluent Python reader would pause, simplify.
- Add type hints to all new public function signatures. Internal helpers (prefixed `_`) may omit hints if the types are obvious from context.
- Docstrings: if the name and signature make the contract self-evident (PEP 257), a single summary line is the complete docstring — do not add more. When the contract isn't obvious, add Google-style Args/Returns/Raises; keep each field a phrase or short clause, not a prose paragraph.
- If a function exists to encode a non-obvious design decision (not just logic), say so in the docstring summary — one clause. "Clips before normalizing to avoid division instability" is load-bearing; "adds two numbers" is not.
- Both docstrings and comments: minimize explanatory prose. Prefer structured information — Args/Returns/Raises fields, brief inline notes — over sentences and paragraphs. If it can be said in a phrase, don't write a sentence.
- Comment only when the reader can't see *why* from a quick pass — dense control flow, shape/index alignment, sampling logic, fallback paths, cross-helper coordination. If still non-obvious after simplification, comment at point of use.
- Explain *why* a choice was made when the alternative was reasonable: a skipped optimization, a deliberate constraint, a non-obvious invariant. One phrase is enough.
- For scripts with runtime stages, add concise stage-level logging (active phase, resolved choices, output writes).

### REPL Scripts and Notebooks
Use VS Code interactive cells: `# %% [markdown]` + title, then `# %%` per runnable block. Section top-level flow only; don't create dozens of tiny cells.

### Python Environment
- Activating in `Bash` tool calls (non-interactive subshells): prefer `mamba activate <env>` if `mamba` is on PATH (single command, no sourcing). Otherwise use the portable form `source "$(conda info --base)/etc/profile.d/conda.sh" && conda activate <env>` — `conda info --base` resolves the right path on whatever machine you're on. Never hardcode `/abs/path/conda.sh`; that would require a per-machine allowlist entry.
- `Bash(ruff format *)` is intentionally allowlisted in some projects even though it writes files in place. Don't suggest narrowing it to `--check`/`--diff` only during permission-allowlist cleanups; the user has weighed the safety cost.

### Python Verification
After Python edits, the tidy+review pass includes running `ruff`, `pylint`, and a targeted syntax or smoke check, unless told not to.

### Review
- After any non-trivial edit, produce a brief change summary: what was changed, what was deliberately left alone, and any decisions that had alternatives worth knowing about.
- If a design choice has a meaningful tradeoff (e.g. chose X over Y because Z), surface it — don't bury it in the implementation. The user should be able to disagree before it becomes load-bearing.
