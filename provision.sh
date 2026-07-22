#!/usr/bin/env bash
# ~/.claude/provision.sh - modular, OPTIONAL per-machine provisioning.
#
# Called (if present + executable) from sync.sh; entirely optional - delete it and
# sync.sh degrades gracefully (its call is guarded). Keep every step IDEMPOTENT so
# it is safe to re-run every session. Job: make synced ~/.claude configs land where
# tools look for them on this machine, WITHOUT baking machine glue into the configs.
# Shell (not Python) on purpose: no interpreter-version constraint.
set -uo pipefail

# rumdl/ruff: their user-global configs have no env-var override, so a symlink
# at the XDG location is the sync mechanism: ~/.config/<tool>/<tool>.toml ->
# the synced ~/.claude copy. Create ONLY if the target is absent - never
# clobber a real file a machine may already have. (ruff's user config applies
# only when a project has no own ruff config.)
for tool in rumdl ruff; do
  if [ -f "$HOME/.claude/$tool.toml" ] && [ ! -e "$HOME/.config/$tool/$tool.toml" ]; then
    mkdir -p "$HOME/.config/$tool"
    ln -s "$HOME/.claude/$tool.toml" "$HOME/.config/$tool/$tool.toml"
  fi
done

exit 0
