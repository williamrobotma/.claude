---
description: Push the ~/.claude config to its remote via the haiku sync-pusher subagent (gated, backgrounded, off the main context)
---
Delegate the push to the `sync-pusher` subagent (Agent tool, subagent_type: sync-pusher).
- Do NOT run `sync.sh` yourself.
  - Keep the git/log chatter in the haiku agent's isolated context.
- Relay its final result.
- If it reports a merge conflict it could not resolve:
  - help me resolve the reported file/hunk,
  - then re-run the push.
