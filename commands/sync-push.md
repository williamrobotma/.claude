---
description: Commit and push the ~/.claude config repo to its remote (gated)
---
Push the local ~/.claude config to its git remote.

1. If you changed config this session, run `bash ~/.claude/sync.sh save` first: `push` ships commits only, not the working tree (the SessionEnd hook auto-saves, but has not run mid-session).
2. Run `bash ~/.claude/sync.sh push` (it merges in the remote, then pushes).
3. Show the last few lines of `~/.claude/sync.log` so I can see the result.

If the push did not succeed, read the git error in the log:
- "Permission denied (publickey)" or a network error -> an auth/connectivity issue
  (e.g. the SSH key is not unlocked into the agent); fix access and retry, no merge needed.
- merge conflict -> the merge is in progress with conflict markers; help me resolve
  them in CLAUDE.md / settings.json, then `git -C ~/.claude add <file>` and
  `git -C ~/.claude commit`, and run the push again.
