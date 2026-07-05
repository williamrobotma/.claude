---
description: Push ~/.claude config via the haiku sync-pusher subagent (backgrounded, off the main context)
---
Delegate the push to the `sync-pusher` subagent (Agent tool, subagent_type:
sync-pusher). Do NOT run `sync.sh` yourself: the point is to keep the git/log
chatter in the haiku agent's isolated context. Just relay its final result.
