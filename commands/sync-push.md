---
description: Push the ~/.claude config to its remote via the haiku sync-pusher subagent (gated, backgrounded, off the main context)
---
Review gate first - the repo is PUBLIC, and SessionEnd auto-commits new files without review, so the push is the last checkpoint before publication:

1. Run `bash ~/.claude/sync.sh save` so working-tree edits are committed and reviewable.
2. Show me the outgoing delta:
   - `git -C ~/.claude log --oneline @{u}..HEAD`
   - `git -C ~/.claude diff @{u}...HEAD` (three-dot: since merge-base, so a diverged remote isn't shown reversed)
   - Nothing outgoing -> report "up to date", stop.
3. Flag anything that looks sensitive (credentials, tokens, private paths/hostnames, project details in lessons/rules), then ask me to approve the push. No approval -> stop; nothing is pushed.

Then delegate the push to the `sync-pusher` subagent (Agent tool, subagent_type: sync-pusher).
- Do NOT run `sync.sh push` yourself.
  - Keep the git/log chatter in the haiku agent's isolated context.
- Relay its final result.
- If it reports a merge conflict it could not resolve:
  - help me resolve the reported file/hunk,
  - then re-run the push.
