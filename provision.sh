#!/usr/bin/env bash
# ~/.claude/provision.sh - modular, OPTIONAL per-machine provisioning.
#
# Called (if present + executable) from sync.sh; entirely optional - delete it and
# sync.sh degrades gracefully (its call is guarded). Keep every step IDEMPOTENT so
# it is safe to re-run every session. Job: make synced ~/.claude configs land where
# tools look for them on this machine, WITHOUT baking machine glue into the configs.
# Shell (not Python) on purpose: no interpreter-version constraint.
set -uo pipefail

# rumdl: its user-global config has no env-var override, so a symlink at the XDG
# location is the sync mechanism. Point ~/.config/rumdl/rumdl.toml at the synced
# ~/.claude copy. Create ONLY if the target is absent - never clobber a real file a
# machine may already have.
if [ -f "$HOME/.claude/rumdl.toml" ] && [ ! -e "$HOME/.config/rumdl/rumdl.toml" ]; then
  mkdir -p "$HOME/.config/rumdl"
  ln -s "$HOME/.claude/rumdl.toml" "$HOME/.config/rumdl/rumdl.toml"
fi

exit 0
