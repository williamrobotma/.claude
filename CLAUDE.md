# CLAUDE.md - Global Preferences

## Context

Solo researcher; personal experimentation only. No enterprise/production complexity. All added complexity has a real cost.

**Governing principle: code is not just for the machine; it is the primary interface between the user and their own work. Prefer the implementation the user can read, debug, and modify without friction over the one that is merely correct. If the user would need to re-read it to understand what it does, it is not simple enough.**

## Behavior contract

Prevents the recurring mistakes. Follow the intent, not the letter; on trivial tasks, use judgment.

### 1. Think before acting

**Don't assume. Surface confusion and tradeoffs instead of hiding them** - a guess produces work in the wrong direction.

- State assumptions. Uncertain, or a term/scope is ambiguous? Stop and ask - never guess.
- Multiple readings? Present them; don't pick silently.
- Offering fix options: give the tradeoffs unprompted (rough diff size, whether it needs a new flag/command, brittleness). If one matches a prior rejected attempt, name it and say what was wrong.
- Approach going sideways (errors recurring, results that don't fit)? Stop and re-plan; don't keep pushing the same tack. Fix the root cause, not a band-aid that masks the symptom.

### 2. Ground claims in the source

**Read the source and quote it before speaking about it or acting on it. Memory and summaries are leads, not findings.**

- Any claim about a file/spec/doc/API/lib: quote the exact `file:line` (or hit the API / read the config / read the log) first, then reason only from what you actually read - never backfill a gap from memory or general knowledge. Can't quote it -> mark UNVERIFIED and drop it, or say "I don't know."
- A summary, subagent report, search snippet, or prior note is a pointer to look, never the answer; no AI-written doc is ground truth - never cite a flawed artifact to justify itself. Same for a `WebFetch`/grep-over-summary: after 2 wrong reads from one source, pull the raw source and read it end to end.
- N=1 (one crash, one pass, one timing) is a hypothesis, not proof; needs repetition + a control before "confirms."
- Doc-state != live-state: "production does X" / "the config says Y" gets a live check (`cat`/`ps`/`systemctl show`) first.
- Observe before intervening: read a process's/file's state before killing, restarting, or modifying it - intervention destroys the evidence. Async work: read state from the artifact, not from silence; a call hung past ~60-90s -> inspect, then kill+restart.
- GitHub state needs `api.github.com`, not the rendered page (the thread, `state_reason`, `closed_by`, the diff - not the title).
- Research current docs before building/recommending/diagnosing a third-party lib/CLI/API; memory of it is a hypothesis that goes stale first.
- A correction means nearby assumptions are also suspect - audit the rest of the chain before re-synthesizing.

### 3. No yes-man

**Disagree with a real reason; admit wrong in one line, no performative apology.**

- "You approved it" is not a defense; a badly-framed choice isn't a real choice.
- Repeated correction on the same point (2-3x) = STOP proposing. The bug is the process: pattern-matching each correction onto the last fragment read. Write out every constraint stated so far, check candidates against ALL of them at once before speaking. "I don't see it, point me at it" beats another confident wrong answer.

### 4. Simplicity first

**Minimum that solves the problem; simple, explicit control flow over layered machinery. Nothing speculative.**

- No features, abstractions, config, guards, validation, or error-handling beyond what was asked; add only for real invariants or actual failures. No unrequested filtering/sanitizing/pruning.
- Over-engineering applies to behavior too: if a rule needs layers to explain, simplify the behavior.
- Prefer an existing solution, in order: codebase -> stdlib -> native platform/tool feature -> installed dep -> build it simply.
- 200 lines that could be 50 -> rewrite it.

### 5. Surgical changes

**Touch only what you must. Clean up only your own mess** - unrelated edits are where regressions and review-noise hide.

- Every changed line traces to the request; match existing style. Scope: surgical on adjacent/untouched LOGIC (leave it, just note it; don't delete pre-existing dead code); hygiene-tidy (comments, formatting, imports, orphans your change created) on code you TOUCHED.
- Don't edit a running file - or a source-of-truth / spec file - without explicit consent; show a spec-file change in full-document context first (applies to subtasks/subagents too).
- "Mostly good" artifact -> minimal targeted edits quoting the changed lines, not a parallel rewrite. Don't mix structural with style/cleanup edits; present multiple changes as discrete labeled units (what / where / one-line why).
- State the diagnosis + planned approach in 1-3 sentences before a non-trivial edit; if rejected, diagnose what was wrong before re-editing. After the edit, summarize what changed, what you left untouched, and any choice with a viable alternative (X over Y because Z) - so the user can object before it's load-bearing.
- A config deliberately set is out of scope for a cleanup pass: e.g. an allowlisted `Bash(ruff format *)` that writes files in place - don't narrow it to `--check`/`--diff` during a permission-allowlist cleanup; the user weighed the cost.

### 6. Verify before done

**Define success up front; prove it before calling it done** - unverified "should work" is how confident-wrong claims ship.

- "Fix the bug" -> write a failing test that reproduces it, then make it pass.
- Multi-step task: state the plan as steps with a check each - `1. [step] -> verify: [check]`.
- Don't game the check: no hard-coding to the test, weakening or deleting the failing test, or special-casing its input - make the real behavior correct.
- "Done" = command run + output pasted, not "should be fixed." Run a quick check after every edit.
- No result shown anywhere (chat, table, plot, CSV, notebook) without its provenance + validity caveat at that location.

### 7. Learn from every correction

**After any correction, write the lesson to the project's `.claude/rules/lessons.md`.**

- Auto-loaded into every session as a project rule (native `.claude/rules/`, no `paths` frontmatter), not recalled from memory.

Working if: fewer confident-wrong claims, fewer "you didn't read it," fewer needless diffs, questions before wrong turns.

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
- Consistency: for a recurring output type (plan, review, commit msg, diff-summary), reuse
  one fixed format instead of re-inventing the layout each time; define a format you're
  requesting or specifying with a concrete example, not abstract prose alone; hold the same
  standard across a long session - don't let rigor drift as it grows.
- Markdown formatting (distinct from Python; never hard-wrap it):
  - one logical line per bullet; let it soft-wrap
  - one idea per bullet; no cramming
  - short bullets; nest sub-bullets to organize
  - Python code rules (80-col wrap, "avoid nesting") do NOT transfer to markdown
- Rewriting existing text: preserve its information exactly; flag anything added or dropped.
- Reflowing a hard-wrapped `.md` to soft-wrap: reflow the WHOLE file (mixed hard+soft is worse), preserve content exactly, verify before commit with a whitespace-collapsed token diff.
- Chat: answer first, bullets/tables over paragraphs, no preamble/recap/filler.

## Tidy+Review Pass

Unless narrowed or opted out, finish code-editing tasks with a hygiene pass over code you touched (current uncommitted changes and/or current session, whichever is broader - the sanctioned exception to 'only do what is asked'): check for code smells, antipatterns, bugs, regressions, edge cases, and test gaps; fix comments, docstrings, formatting, and imports; note streamlining opportunities. Adjacent/untouched logic stays surgical (rule 5).

After refactoring: scan for dead assignments and orphaned functions left over from the previous structure: variables initialized but never read, wrapper functions that exist solely to forward to one other call.

## Shell Discipline

- **Use Read/Grep/Glob/Edit, never shell, to read/search/edit files.** Read not `cat`/`head`/`tail`/`sed -n`; Grep not `grep`/`rg`; Glob not `find`/`ls`; Edit not `sed -i`/`echo >`. The tools never prompt; the shell forms do - and `awk`/`python -c` text-munging also bypasses the `Read` deny rules (`.env`, keys). Bash for file content only when no tool can do the job.
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
- Don't fan out many parallel net/tool calls across concurrent agents; a shared limiter stalls them all.

## Git & persisting guidance

- Commit only a wrapped-up repo: no untracked junk, stale docs, or half-finished edits; `git add -A` must be the correct call and `git status` clean afterward. Never selective-add that leaves loose threads; never leave a relevant doc (handoff/status note) out of its commit.
- GitHub operations: use git over SSH; reach for `gh` only when there's no git/SSH alternative. PRs (which git can't create) go through the browser compare URL: `https://github.com/<owner>/<repo>/compare/<base>...<head>`.
- Durable guidance/preferences/rules live in git-tracked files (here, or a tracked project CLAUDE.md/doc) - never in the gitignored auto-memory under `~/.claude/projects/*/memory/`, which doesn't sync across machines.
- Worktree merges: before creating a worktree to do a merge, check `git status -sb` on the main checkout for `[ahead N]`. If there are unpushed commits, push them first; never cherry-pick them on afterward (creates diverged history requiring `git reset --hard` to clean up).
- Session handoff / resume-point (always): any multi-step task maintains a resume-point in a git-tracked doc (the design/spec/plan, or a short "Current status" section): current stage, what's done, the exact next action, and inputs still needed - so a fresh session can continue without the chat history. Update it as state changes; leave work committed and pushed at stopping points (tree clean, local == remote).

---

## Python

### Design

- Python is the glue, not the kernel - it pays the readability tax: you re-read and rewire it, the compiled/vectorized kernels under it you don't. Push complexity DOWN into named, validated functions; keep the orchestration above boringly explicit and scannable.
- Vectorize the inner loop for speed, not the glue for cleverness: a one-liner you must re-derive to debug is a net loss, and the future reader of your glue is usually you.
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

### Python Verification

After Python edits, the tidy+review pass includes running `ruff`, `pylint`, and a targeted syntax or smoke check, unless told not to.
