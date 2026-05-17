# CLAUDE.md — Global Preferences

## Interpreting Instructions
Treat hedged phrasing ("may", "should", "could", "if possible", "try to", "ideally", "maybe", "probably", "I think", "I guess", "favour") as real instructions, not suggestions. Apply throughout the whole task. Keep user corrections active for the rest of the task without re-asking.

## Core Behavior
- Only do what is asked; no unrequested changes or features.
- Ask for clarification when ambiguous; never guess.
- "Over-engineered" applies to behavior too — if it needs layered rules to explain, simplify the behavior first.
- Don't add filtering, sanitizing, or pruning unless asked or clearly required for correctness.
- Don't edit currently running files without explicit approval.
- After edits, run a quick verification.
- When revising an artifact the user has signaled is "mostly good" (a plan, doc, or code file), produce minimal targeted edits — not a parallel rewrite. Quote the specific lines/sections being changed and the replacement text; don't restate unchanged scaffolding.

## Tidy+Review Pass
Unless narrowed or opted out, finish code-editing tasks with a pass over touched code: check for bugs, regressions, edge cases, and test gaps; fix comments, docstrings, formatting, and imports; note streamlining opportunities. Scope: current uncommitted changes and/or current session, whichever is broader.

After refactoring: scan for dead assignments and orphaned functions left over from the previous structure — variables initialized but never read, wrapper functions that exist solely to forward to one other call.

## Shell Discipline
- Prefer workspace-relative paths; use absolute only when a tool requires it.
- Use bare binary names (ruff, pylint, etc.); rely on PATH or the active venv.
- Print lint/test output directly; don't redirect to /tmp or out-of-workspace paths.

---

## Python

### Context
Solo researcher; personal experimentation only. No enterprise/production complexity. All added complexity has a real cost.

### Design
- Least complex solution that works; simple, explicit control flow over layered machinery.
- No speculative guards, validation, or branching; add only for real invariants or actual failures.
- Main path scannable top-to-bottom. Definitions near use. Inline single-use helpers; extract only genuinely reused or dense logic.
- Prefer the clearest standard construct over clever convenience helpers or hand-rolled machinery when both do the same job. Use `==` over `.equals()` or `.eq()`, use for loops and comprehensions over `map` and `filter`, use slicing and built-ins like `zip`, `enumerate`, `sorted`, `reversed`, `any`, `all`, `sum`, `min`, `max`, `len`, etc. over custom helpers that do the same thing.
- joblib.Parallel job wrapper functions must be ≤3 lines (name, call, return). If longer, restructure the called function instead.
- For multi-axis iteration, prefer `itertools.product` over triple-nested list comprehensions.
- When multiple callables share a dispatch pattern (name → fn + fixed kwargs), encode as a `dict[str, Callable]` using `functools.partial` to pre-bind kwargs — not as `(name, fn, kwargs)` tuples passed around.

### Performance
- Keep hot-path ops device-resident; avoid per-iteration GPU↔CPU syncs (`.item()`, `.cpu()`) unless required.

### Style
- PEP 8 and PEP 257 unless the repo deviates.
- Add type hints to all new public function signatures. Internal helpers (prefixed `_`) may omit hints if the types are obvious from context.
- Docstrings: if the name and signature make the contract self-evident (PEP 257), a single summary line is the complete docstring — do not add more. When the contract isn't obvious, add Google-style Args/Returns/Raises; keep each field a phrase or short clause, not a prose paragraph.
- Both docstrings and comments: minimize explanatory prose. Prefer structured information — Args/Returns/Raises fields, brief inline notes — over sentences and paragraphs. If it can be said in a phrase, don't write a sentence.
- Comment only when the reader can't see *why* from a quick pass — dense control flow, shape/index alignment, sampling logic, fallback paths, cross-helper coordination. If still non-obvious after simplification, comment at point of use.
- For scripts with runtime stages, add concise stage-level logging (active phase, resolved choices, output writes).

### REPL Scripts and Notebooks
Use VS Code interactive cells: `# %% [markdown]` + title, then `# %%` per runnable block. Section top-level flow only; don't create dozens of tiny cells.

### Python Environment
- Activate the workspace's Python environment before any Python-adjacent tool; invoke bare commands (`python`, `ruff`, `pylint`, `pytest`). No `conda run`, `poetry run`, or `python -m` wrappers unless unavoidable.
- For package installs or environment mutation, show the exact command and get approval first.
- Activating in `Bash` tool calls (non-interactive subshells): prefer `mamba activate <env>` if `mamba` is on PATH (single command, no sourcing). Otherwise use the portable form `source "$(conda info --base)/etc/profile.d/conda.sh" && conda activate <env>` — `conda info --base` resolves the right path on whatever machine you're on. Never hardcode `/abs/path/conda.sh`; that would require a per-machine allowlist entry.
- `Bash(ruff format *)` is intentionally allowlisted in some projects even though it writes files in place. Don't suggest narrowing it to `--check`/`--diff` only during permission-allowlist cleanups; the user has weighed the safety cost.

### Python Verification
After Python edits, the tidy+review pass includes running `ruff`, `pylint`, and a targeted syntax or smoke check, unless told not to.
