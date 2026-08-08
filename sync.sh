#!/usr/bin/env bash
# Sync ~/.claude config with its git remote.
#
#   sync.sh save   SessionEnd hook:   commit local changes locally; NO network.
#   sync.sh status SessionStart hook: note a push backlog; read-only, NO network.
#   sync.sh pull   interactive:       merge in the remote (run at session start).
#   sync.sh push   interactive:       merge in the remote, then push (gated step).
#
# Only `save` runs from a hook (local commit, no auth). pull/push touch the
# network and run only in an interactive session, where your SSH agent /
# credentials are loaded - hooks have no agent and bypass the permission system.
# pull/push MERGE rather than fast-forward-only: divergence is reconciled, never
# silently overwritten or deleted; the merge stops on conflict for you to resolve.
# `save` always exits 0 so a hook never stalls a session; the interactive
# pull/push print an explicit ok/FAILED to stdout and exit non-zero on failure
# so the caller can detect it (silence is not success). Logs to ~/.claude/sync.log.
set -uo pipefail

repo="$HOME/.claude"
log="$repo/sync.log"
cd "$repo" 2>/dev/null || exit 0
note() { echo "$(date '+%F %T') $*" >>"$log"; }

# `status` is the SessionStart surface for a push backlog, which `save` otherwise
# only ever writes to the log. Read-only, so it returns before the setup below -
# it needs none of it, and a session start should not wait on provision.sh.
# Threshold: 1-3 ahead is the steady state (147 of 229 saves), so only >=5 is
# worth a line - surfacing the common case would say nothing.
if [ "${1:-}" = status ]; then
  if ! ahead="$(git rev-list --count @{u}..HEAD 2>/dev/null)"; then
    echo "~/.claude: cannot resolve @{u} - no upstream, or detached HEAD. Push state unknown."
  elif [ "$ahead" -ge 5 ]; then
    echo "~/.claude: $ahead commits unpushed (run /sync-push)."
  fi
  exit 0
fi

# Two runs can overlap - a SessionEnd save while another session pushes - and then
# race on git's index or HEAD. Both failures are already in sync.log (index.lock,
# ref CAS) and `save` exits 0, so they vanish. Serialize whole runs, and cap the
# wait so a session end never stalls behind an interactive push.
# Each failure reports its own cause: a lock we cannot open is not a busy lock,
# and a skipped pull/push is not a success ("silence is not success", above).
git_dir="$(git rev-parse --git-dir 2>/dev/null)" || git_dir="$repo/.git"
if ! exec 9>"$git_dir/sync.lock"; then
  note "lock: cannot open $git_dir/sync.lock"
  [ "${1:-}" = save ] || echo "${1:-}: FAILED - cannot open the sync lock. See $log"
  exit 0
fi
# Git Bash on Windows ships no flock; run unlocked there (the pre-lock behavior)
# rather than failing every sync, and keep the gap visible in the log.
if ! command -v flock >/dev/null 2>&1; then
  note "lock: flock unavailable on this host, proceeding unlocked"
elif ! flock -w 30 9; then
  note "lock: busy >30s, skipped ${1:-}"
  # A skipped `save` loses nothing - the tree stays dirty for the next one.
  [ "${1:-}" = save ] && exit 0
  echo "${1:-}: FAILED - another sync.sh held the lock for 30s; nothing done. See $log"
  exit 1
fi

# Commit a dirty tree locally (no network). Used by `save` and before `push`'s
# pull - /model and /effort write settings.json mid-session, and a dirty tree
# makes that pull refuse ("local changes would be overwritten by merge").
commit_pending() {
  [ -n "$(git status --porcelain)" ] || return 0
  git add -A
  git commit -q -m "auto-save $(hostname) $(date '+%F %T')" 2>>"$log" \
    || note "save: commit FAILED - tree still dirty (the ahead count will not move)"
}

# Hooks / the editor's `bash -c` don't source ~/.bashrc, so the shared ssh-agent
# socket isn't in their env. Point at it here (keep any already-set value) so
# pull/push can reach the agent. The agent + key load are managed by ~/.bashrc.
export SSH_AUTH_SOCK="${SSH_AUTH_SOCK:-$HOME/.ssh/agent.sock}"

# Some past tool pinned a per-session SSH_AUTH_SOCK into git's core.sshCommand;
# that socket dies with its session and then silently breaks every git-over-ssh
# op here (Permission denied). We export the stable socket above, so drop any
# such /tmp pin and let git inherit it.
git config --local --get core.sshCommand 2>/dev/null | grep -q '/tmp/ssh-' \
  && { git config --local --unset core.sshCommand; note "repaired: dropped stale /tmp core.sshCommand"; } || true

# Register the settings.json merge driver named in .gitattributes. The name->command
# map lives in per-clone git config, not the repo, so (re)set it here; idempotent.
git config merge.claude-settings.driver 'python3 "$HOME/.claude/merge-settings.py" %O %A %B'

# Optional, modular per-machine provisioning (idempotent symlinks etc.). Its own
# file; delete it and this line no-ops. Never allowed to fail the sync.
[ -x "$repo/provision.sh" ] && "$repo/provision.sh" >>"$log" 2>&1 || true

case "${1:-}" in
  pull)
    if git pull --no-rebase --no-edit --quiet 2>>"$log"; then
      note "pull: ok"; echo "pull: ok"
    else
      note "pull: failed or conflicted - resolve in the working tree (see git error above)"
      echo "pull: FAILED - conflicted or unreachable; see $log"; exit 1
    fi
    ;;
  save)
    commit_pending
    ahead="$(git rev-list --count @{u}..HEAD 2>/dev/null || echo 0)"
    [ "$ahead" -gt 0 ] && note "save: $ahead commit(s) pending push (run /sync-push)"
    ;;
  push)
    commit_pending  # else a mid-session /model or /effort edit blocks the pull
    if ! git pull --no-rebase --no-edit --quiet 2>>"$log"; then
      git merge --abort 2>/dev/null
      note "push: aborted - pull failed or conflicted; merge aborted (nothing committed); run 'sync.sh pull' to resolve, then retry (see git error above)"
      echo "push: FAILED - pull conflicted or unreachable before push; nothing pushed. See $log"; exit 1
    fi
    if git push --quiet 2>>"$log"; then
      note "push: ok"; echo "push: ok"
    else
      note "push: failed (see git error above)"
      echo "push: FAILED - git push failed; nothing pushed. See $log"; exit 1
    fi
    ;;
  *)
    note "usage: sync.sh save|status|pull|push"
    ;;
esac
exit 0
