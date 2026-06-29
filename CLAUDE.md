# CLAUDE.md - Global Preferences
## Context
Solo researcher; personal experimentation only. No enterprise/production complexity. All added complexity has a real cost.

**Governing principle: code is not just for the machine; it is the primary interface between the user and their own work. Prefer the implementation the user can read, debug, and modify without friction over the one that is merely correct. If the user would need to re-read it to understand what it does, it is not simple enough.**

## Core Behavior
- Only do what is asked; no unrequested changes or features.
- Ask for clarification when ambiguous; never guess.
- "Over-engineered" applies to behavior too: if it needs layered rules to explain, simplify the behavior first.
- Don't add filtering, sanitizing, or pruning unless asked or clearly required for correctness.
- **Research before building.** Verify from current docs, not memory (training lags fast-moving tools) that the need isn't already met before adding code or steps.
- **Prefer an existing solution over a custom one.** When something is needed, find it before building it, in order:
  - Already in the codebase? Reuse it; don't rewrite.
  - In the stdlib? Use it.
  - A native platform or tool feature? Use it.
  - An installed dependency? Use it.
  - None of the above? Build it, as simply as possible.
- Don't edit currently running files without explicit approval.
- **Use Read/Grep/Glob/Edit, never shell, to read/search/edit files.** Read not `cat`/`head`/`tail`/`sed -n`; Grep not `grep`/`rg`; Glob not `find`/`ls`; Edit not `sed -i`/`echo >`. The tools never prompt; the shell forms do - and `awk`/`python -c` text-munging also bypasses the `Read` deny rules (`.env`, keys). Bash for file content only when no tool can do the job.
- After edits, run a quick verification.
- When revising an artifact the user has signaled is "mostly good" (a plan, doc, or code file), produce minimal targeted edits, not a parallel rewrite. Quote the specific lines/sections being changed and the replacement text; don't restate unchanged scaffolding.
- When making multiple changes, present them as discrete labeled units, not interleaved in a wall of output. Each unit: what changed, where, and one-line why. Unrelated changes get separate units even if delivered together.
- Don't mix structural changes with style/cleanup changes in the same edit. Flag cleanup separately so the user can accept or skip it without untangling it from logic changes.
- Before a non-trivial edit, state the diagnosis and planned approach in 1-3 sentences. Edit only after that's on the page. If the edit is rejected, don't re-edit; diagnose what the user didn't like before trying again.
- When offering fix options, surface trade-offs proactively: rough diff size, user-facing impact (does it need a new flag? command change?), brittleness; and if one option matches a prior rejected attempt, name it and say what was wrong. Don't make the user fish for this.

## Diagnosis & Honesty
- Look before explaining. On "what's going on" or any surprise, read the primary artifact (log, transcript, output, the file) before naming a cause - inference from priors is not diagnosis. Never present a guess as one (mark "guessing" vs "the log shows"); "still running / standing by / I'll proceed" is not an answer.
- Observe before intervening. Don't kill, restart, or modify what you're diagnosing before reading its state; intervention destroys the evidence.
- Verify cheap-to-check limits before obeying: a file's actual size vs a generic "will overflow context" warning. Not license to bypass real constraints (key/.env deny-rules, "don't edit running files", safety gates).
- Async work: read state from its artifact, don't infer from silence. An in-flight call past ~60-90s is likely hung - inspect, then kill+restart to unblock. Don't fan out many parallel net/tool calls across concurrent agents; a shared limiter stalls them all.

## Writing (comments, docstrings, commit messages, chat)
- ASCII only (standard ANSI keyboard). No Unicode symbols: `->` not the arrow glyph,
  `<-` / `<-->` for left/bidirectional, `x` not the multiply sign, `-` not middot.
- Em-dash: use `:` or `;` where applicable, else ` - `. Pick the best separator for the
  context; it need not be prose punctuation (`->`, `|`, `:` are fine in structured text).
- No hand-aligned whitespace columns or ASCII boxes in docstrings; use Args:/Returns:/Notes:.
- Concise = dense per word, not fewer facts and not fewer lines. Keep every fact,
  shape, example, citation (turn prose into bullets/fields; don't abbreviate domain
  terms - `cell_line`, not `line`), but don't cram ideas onto one line to save
  lines; separate them with newlines and sub-bullets.
- Rewriting existing text: preserve its information exactly; flag anything added or dropped.
- Chat: answer first, bullets/tables over paragraphs, no preamble/recap/filler.

## Tidy+Review Pass
Unless narrowed or opted out, finish code-editing tasks with a pass over touched code: check for code smells, antipatterns, bugs, regressions, edge cases, and test gaps; fix comments, docstrings, formatting, and imports; note streamlining opportunities. Scope: current uncommitted changes and/or current session, whichever is broader (the sanctioned exception to 'only do what is asked').

After refactoring: scan for dead assignments and orphaned functions left over from the previous structure: variables initialized but never read, wrapper functions that exist solely to forward to one other call.

## Shell Discipline
- Prefer workspace-relative paths; use absolute only when a tool requires it.
- Use bare binary names (ruff, pylint, etc.); rely on PATH or the active venv.
- Never `awk`/`gawk`/`mawk` (a PreToolUse hook denies it, so reaching for it wastes a
  turn). Field/column extraction from command output -> `cut`/`grep`/`sort`/`sed`; file
  contents -> Read. awk's `system()`/`getline` bypass the Read deny-rules.
- No foreground `sleep`; the harness blocks it (exit ~144) and aborts your script mid-run.
  Poll with a background command or the Monitor tool.
- Kill by PGID, not `pkill -f <pattern>`: if the pattern appears in your own command line,
  pkill matches and kills the wrapper shell first. Use
  `kill -KILL -$(ps -o pgid= -p <pid> | tr -d ' ')`.

## Git & persisting guidance
- Commit only a wrapped-up repo: no untracked junk, stale docs, or half-finished edits; `git add -A` must be the correct call and `git status` clean afterward. Never selective-add that leaves loose threads; never leave a relevant doc (handoff/status note) out of its commit.
- GitHub operations: use git over SSH; reach for `gh` only when there's no git/SSH alternative. PRs (which git can't create) go through the browser compare URL: `https://github.com/<owner>/<repo>/compare/<base>...<head>`.
- Durable guidance/preferences/rules live in git-tracked files (here, or a tracked project CLAUDE.md/doc) - never in the gitignored auto-memory under `~/.claude/projects/*/memory/`, which doesn't sync across machines.

---

## Python

### Design
- Python is the glue, not the kernel - it pays the readability tax: you re-read and rewire it, the compiled/vectorized kernels under it you don't. Push complexity DOWN into named, validated functions; keep the orchestration above boringly explicit and scannable.
- Vectorize the inner loop for speed, not the glue for cleverness: a one-liner you must re-derive to debug is a net loss, and the future reader of your glue is usually you.
- Least complex solution that works; simple, explicit control flow over layered machinery.
- No speculative guards, validation, or branching; add only for real invariants or actual failures.
- Fail-visible over silent-skip: a guard that quietly returns on unexpected-empty/degenerate input hides bugs. Let it surface (blank output, error) unless that state is known and benign.
- `assert` only for internal invariants/self-checks (stripped by `python -O`); validate external input / runtime conditions with real exceptions - prefer `try/except` around the failing op, else an explicit `raise` (e.g. `ValueError`) when there's no operation to wrap. (Google Python style guide)
- Prefer the clearest standard construct over clever convenience helpers or hand-rolled machinery when both do the same job. Use `==` over `.equals()` or `.eq()`, use for loops and comprehensions over `map` and `filter`, use slicing and built-ins like `zip`, `enumerate`, `sorted`, `reversed`, `any`, `all`, `sum`, `min`, `max`, `len`, etc. over custom helpers that do the same thing.
- joblib.Parallel job wrapper functions must be <=3 lines (name, call, return). If longer, restructure the called function instead.
- Avoid unnecessary:
  - nesting (use itertools),
  - multi-line list comprehensions,
  - nested unpacking in a single line (e.g., do `for k, _ in zip(a_dict, a_list)` instead of `for (k,v), _ in zip(a_dict.items(), a_list)` if it exceeds formatter line-length limits)
- Use `with` statements for all resource management (files, connections, locks). Never open without a context manager.
- When there is one obvious, standard way to do something, use it. Don't reach for a custom solution when an idiom or tool exists.
- Explicit over implicit: code should show what it does, not hide it behind abstraction, magic, or indirection. When a function's behavior differs by caller, use a named keyword parameter (`paths_only=True`); not attribute-presence checks (`hasattr(args, "profile")`) or other implicit signals. Named flags document the contract; presence checks just happen to work given today's setup.
- When multiple callables share a dispatch pattern (name -> fn + fixed kwargs), encode as a `dict[str, Callable]` using `functools.partial` to pre-bind kwargs, not as `(name, fn, kwargs)` tuples passed around.
- Typing: Unless otherwise required, prefer abstract, covariant type hints such as `Sequence` or `Iterable` over brittle, specific, and invariant types such as `list` (e.g., neither `list[Dog]` nor `Tuple[Animal]` are `list[Animal]`, but both are `Sequence[Animal]`).

### Style
- PEP 8 and PEP 257 unless the repo deviates. Docstrings and comments follow **Google style** and wrap at **80 cols** (even where code allows more, e.g. ruff 88). This 80-col wrap is for Python docstrings/comments only - never hard-wrap Markdown or prose.
- Prefer the form that reads closest to plain English. If a fluent Python reader would pause, simplify.
- Add type hints to all new public function signatures. Internal helpers (prefixed `_`) may omit hints if the types are obvious from context.
- Docstrings: if the name and signature make the contract self-evident (PEP 257), a single summary line is the complete docstring; do not add more. When the contract isn't obvious, add Google-style Args/Returns/Raises; keep each field a phrase or short clause, not a prose paragraph. Any multi-line function docstring uses these sections; a function that returns gets a `Returns:`; a genuinely non-trivial multi-arg function gets full `Args:`/`Returns:`/`Yields:`/`Raises:`. Private helpers and self-evident wrappers stay one-line.
- If a function exists to encode a non-obvious design decision (not just logic), say so in the docstring summary: one clause. "Clips before normalizing to avoid division instability" is load-bearing; "adds two numbers" is not.
- Both docstrings and comments: minimize explanatory prose. Prefer structured information (Args/Returns/Raises fields, brief inline notes) over sentences and paragraphs.
- Comments: prefer symbolic/diagrammatic form over sentences (`(name, split) x condition-level`, `|ctrl| = |gen-of-class|`, `wide->long`, `sum(value*n)/sum(n)`). Name the concrete object/variable (`run_cond`'s panel concat, the saved `weighted` frame), never vague nouns ("the panel"). Explanatory comments go on their own line above the code; reserve trailing comments for short tags on data lines (never let one exceed the line-length limit).
- Comment only the non-obvious *why*. Discriminate by reading the code as whoever will run it: lines that make them ask "why?" get a comment; what they can already see (the loop, the append, a variable's name) does not. Typical why-sites: dense control flow, shape/index alignment, sampling logic, fallback paths, cross-helper coordination. Comment at point of use, after simplifying.
- Explain *why* a choice was made when the alternative was reasonable: a skipped optimization, a deliberate constraint, a non-obvious invariant. Same for added scaffolding (a new parameter, guard, or early return for a specific caller): say why at the *call site*, not only at the definition. One phrase is enough.
- For scripts with runtime stages, add concise stage-level logging (active phase, resolved choices, output writes).

### REPL Scripts and Notebooks
- Use VS Code interactive cells: `# %% [markdown]` + title, then `# %%` per runnable block. Section top-level flow only; don't create dozens of tiny cells.
- Main path scannable top-to-bottom. Definitions near use. Inline single-use helpers; extract only genuinely reused or dense logic.
- Notebooks for exploration; once logic is stable, extract it into an importable `.py` module (testing, reuse, diffs).
- "Restart & Run All" top-to-bottom is the definition of correct; distrust hidden or out-of-order cell state.
- Never comment/uncomment to switch behavior; use `if/else` or a parameter - keeps every path runnable and diff-able.

### Python Environment
- `Bash(ruff format *)` is intentionally allowlisted in some projects even though it writes files in place. Don't suggest narrowing it to `--check`/`--diff` only during permission-allowlist cleanups; the user has weighed the safety cost.

### Python Verification
After Python edits, the tidy+review pass includes running `ruff`, `pylint`, and a targeted syntax or smoke check, unless told not to.

### Review
- After a non-trivial edit, summarize what changed, what you left alone, and any choice with a viable alternative (X over Y because Z) - so the user can object before it's load-bearing.
