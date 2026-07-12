---
paths:
  - "**/*.py"
  - "**/*.ipynb"
---

# Python

- Idiomatic, pythonic code: clear standard constructs over hand-rolled or clever equivalents; keep the main path boringly explicit.
  - e.g. `==` not `.equals`; `with` for resources; no needless nesting.
- Any check the code depends on is a `raise`, never an `assert` - `-O` deletes asserts, so an assert must be deletable too (pytest excepted). Never quietly return/skip on a bad state.
- Explicit over implicit: behavior that differs by caller -> a named keyword (`paths_only=True`), not `hasattr`/presence checks.
- Prefer covariant hints (`Sequence`/`Iterable`) over invariant `list`/`Tuple` on public signatures.
- Docstrings/comments: Google style, wrap 80 (Python only).
  - Depth matches the contract: self-evident name+signature -> one summary line; else Args/Returns/Raises.
  - Comment only the non-obvious why.
- Notebooks and REPL: VS Code `# %%` cells; main path scannable top-to-bottom.
  - "Restart & Run All" is the definition of correct.
  - Once stable, extract logic to an importable `.py`.
  - Never comment/uncomment to switch behavior - use if/else or a parameter.
- Task-end tidy: a PostToolUse hook runs `ruff check` on each `.py` you edit; run pylint yourself on session-touched files before calling the task done.
