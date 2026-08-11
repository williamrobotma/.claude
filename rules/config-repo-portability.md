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
- Symlinks: `ln -s` on Git Bash silently COPIES the file, so a "symlink" freezes at creation time and drifts from the repo.
  - Sync by copy-on-diff on Windows (detect via `APPDATA`; WSL never sets it).
  - Keep the real symlink on Linux/macOS/WSL - Linux is first class (see the rumdl/ruff block in provision.sh).
  - Why: a frozen copy shipped a stale MD013 policy for a month (found 2026-08-10).
- User-global config paths differ by OS: native Windows tools (rumdl, ruff) read `%APPDATA%/<tool>/`, not `~/.config/<tool>/`.
  - Verify the path with a discriminating probe (a setting only that file could supply) before trusting it.
- Python file writes: always `open(..., newline="")` (or binary mode) - Windows Python otherwise rewrites `\n` as `\r\n`, and the repo is LF-only (`.gitattributes: * text=auto eol=lf`). CRLF output corrupted a merge into a whole-file conflict (see merge-settings.py).
- Paths: stick to `$HOME`/`~` and forward slashes; never hardcode `/home/<user>` or `C:/Users/<user>`.
