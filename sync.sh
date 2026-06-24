#!/usr/bin/env bash
# Sync ~/.claude config with its git remote.
#
#   sync.sh save   SessionEnd hook: commit local changes locally; NO network.
#   sync.sh pull   interactive:     merge in the remote (run at session start).
#   sync.sh push   interactive:     merge in the remote, then push (gated step).
#
# Only `save` runs from a hook (local commit, no auth). pull/push touch the
# network and run only in an interactive session, where your SSH agent /
# credentials are loaded - hooks have no agent and bypass the permission system.
# pull/push MERGE rather than fast-forward-only: divergence is reconciled, never
# silently overwritten or deleted; the merge stops on conflict for you to resolve.
# Always exits 0 so it never stalls a session. Logs to ~/.claude/sync.log.
set -uo pipefail

repo="$HOME/.claude"
log="$repo/sync.log"
cd "$repo" 2>/dev/null || exit 0
note() { echo "$(date '+%F %T') $*" >>"$log"; }

# Hooks / the editor's `bash -c` don't source ~/.bashrc, so the shared ssh-agent
# socket isn't in their env. Point at it here (keep any already-set value) so
# pull/push can reach the agent. The agent + key load are managed by ~/.bashrc.
export SSH_AUTH_SOCK="${SSH_AUTH_SOCK:-$HOME/.ssh/agent.sock}"

case "${1:-}" in
  pull)
    git pull --no-rebase --no-edit --quiet 2>>"$log" \
      && note "pull: ok" \
      || note "pull: failed or conflicted - resolve in the working tree (see git error above)"
    ;;
  save)
    if [ -n "$(git status --porcelain)" ]; then
      git add -A
      git commit -q -m "auto-save $(hostname) $(date '+%F %T')" 2>>"$log"
    fi
    ahead="$(git rev-list --count @{u}..HEAD 2>/dev/null || echo 0)"
    [ "$ahead" -gt 0 ] && note "save: $ahead commit(s) pending push (run /sync-push)"
    ;;
  push)
    git pull --no-rebase --no-edit --quiet 2>>"$log" \
      || { note "push: aborted - pull failed or conflicted; resolve, then retry (see git error above)"; exit 0; }
    git push --quiet 2>>"$log" && note "push: ok" || note "push: failed (see git error above)"
    ;;
  *)
    note "usage: sync.sh save|pull|push"
    ;;
esac
exit 0
