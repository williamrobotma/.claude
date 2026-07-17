#!/usr/bin/env python3
"""PreToolUse(Bash) guard: restrict the sync-pusher subagent to sync.sh save/push.

The sync-pusher agent (~/.claude/agents/sync-pusher.md, tools: Bash, Read) exists
only to run `sync.sh save`/`push` and report; those two commands do all git
add/commit/pull/push internally. Bash is its one write vector, so denying every
other Bash command when agent_type == "sync-pusher" stops it editing settings.json
/ the allowlist or hand-resolving a merge conflict - on any failure it is forced to
stop and report to the user. Every other agent (incl. the main loop, where
agent_type is absent) falls through untouched.
"""
import json
import sys

# The only Bash commands sync-pusher needs (each does all git work internally);
# same forms the permission allowlist grants in settings.json.
ALLOWED = {
    "bash ~/.claude/sync.sh save",
    "bash ~/.claude/sync.sh push",
}

try:
    data = json.load(sys.stdin)
except (json.JSONDecodeError, ValueError):
    sys.exit(0)  # unreadable input -> normal permission flow

if data.get("agent_type") != "sync-pusher":
    sys.exit(0)  # only the sync-pusher is restricted

command = (data.get("tool_input") or {}).get("command", "")
if " ".join(command.split()) in ALLOWED:
    sys.exit(0)  # canonical sync.sh save/push -> allow

reason = ("sync-pusher may only run `bash ~/.claude/sync.sh save` or "
          "`bash ~/.claude/sync.sh push`. It must not edit files, change the "
          "permission allowlist, or resolve merge conflicts. If the sync failed "
          "or hit a merge conflict, STOP and report the details to the user to "
          "resolve; do not try to fix it yourself.")
print(json.dumps({"hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": reason,
}}))
sys.exit(0)
