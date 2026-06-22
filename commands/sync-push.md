---
description: Commit and push the ~/.claude config repo to its remote (gated)
---
Push the local ~/.claude config to its git remote.

1. Run `bash ~/.claude/sync.sh push` (it pulls --ff-only, then pushes).
2. Show the last few lines of `~/.claude/sync.log` so I can see the result.

If the push did not succeed, read the git error in the log:
- "Permission denied (publickey)" or a network error -> an auth/connectivity issue,
  not a conflict; fix access (no rebase needed) and retry.
- histories diverged -> run `git -C ~/.claude pull --rebase`, help me resolve any
  conflict in CLAUDE.md / settings.json, then run the push again.
