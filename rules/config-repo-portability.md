---
paths:
  - "**/.claude/sync.sh"
  - "**/.claude/provision.sh"
  - "**/.claude/statusline-command.sh"
  - "**/.claude/merge-settings.py"
  - "**/.claude/hooks/**"
---

# Config-repo scripts must run on Linux AND Git Bash (Windows)

Every script here runs on all synced machines; one of them is Windows + Git Bash. Both rules below broke a real sync (2026-08-04).

- Shell: Git Bash ships coreutils + git and little else - no `flock`, no `systemctl`, etc. Anything beyond coreutils/git needs a `command -v` guard with a working fallback (see the flock fallback in sync.sh).
- Python file writes: always `open(..., newline="")` (or binary mode) - Windows Python otherwise rewrites `\n` as `\r\n`, and the repo is LF-only (`.gitattributes: * text=auto eol=lf`). CRLF output corrupted a merge into a whole-file conflict (see merge-settings.py).
- Paths: stick to `$HOME`/`~` and forward slashes; never hardcode `/home/<user>` or `C:/Users/<user>`.
