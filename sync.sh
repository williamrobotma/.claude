#!/usr/bin/env bash
# Sync ~/.claude config with its git remote. Called by Claude Code hooks.
#
#   sync.sh pull   SessionStart: fast-forward only; never merges, never blocks.
#   sync.sh save   SessionEnd:   commit local changes locally; does NOT push.
#   sync.sh push   deliberate:   pull --ff-only then push (the gated step).
#
# Always exits 0 so it never stalls a session. Logs to ~/.claude/sync.log.
set -uo pipefail

repo="$HOME/.claude"
log="$repo/sync.log"
cd "$repo" 2>/dev/null || exit 0
note() { echo "$(date '+%F %T') $*" >>"$log"; }

case "${1:-}" in
  pull)
    git pull --ff-only --quiet 2>>"$log" || note "pull: failed (auth/network or diverged; see git error above)"
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
    git pull --ff-only --quiet 2>>"$log" || { note "push: aborted - pull failed (auth/network or diverged; see git error above)"; exit 0; }
    git push --quiet 2>>"$log" && note "push: ok" || note "push: failed"
    ;;
  *)
    note "usage: sync.sh pull|save|push"
    ;;
esac
exit 0
