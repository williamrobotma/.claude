---
description: Commit and push the ~/.claude config repo to its remote (gated)
---
Push the local ~/.claude config to its git remote.

1. If you changed config this session, run `bash ~/.claude/sync.sh save` first: `push` ships commits only, not the working tree (the SessionEnd hook auto-saves, but has not run mid-session).
2. Run `bash ~/.claude/sync.sh push` (it merges in the remote, then pushes).
3. Show the last few lines of `~/.claude/sync.log` so I can see the result.

If the push did not succeed, read the git error in the log and handle it by type.

Auth / network ("Permission denied (publickey)", timeouts):
- Cause: SSH key not loaded into the agent, or no connectivity.
- Action: fix access and retry. No merge needed.

Merge conflict (markers left in the working tree):
- settings.json is auto-resolved by the merge-settings.py driver (per-machine prefs kept local, all else merged). A conflict THERE means a driver gap - a per-machine pref missing from PER_MACHINE; fix the set, not the file.
- Other files (CLAUDE.md etc.) are plain text merges - help me resolve them.
- Then `git -C ~/.claude add <file>`, `git -C ~/.claude commit`, and push again.
