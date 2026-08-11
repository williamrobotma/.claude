#!/usr/bin/env bash
# ~/.claude/provision.sh - modular, OPTIONAL per-machine provisioning.
#
# Called (if present + executable) from sync.sh; entirely optional - delete it and
# sync.sh degrades gracefully (its call is guarded). Keep every step IDEMPOTENT so
# it is safe to re-run every session. Job: make synced ~/.claude configs land where
# tools look for them on this machine, WITHOUT baking machine glue into the configs.
# Shell (not Python) on purpose: no interpreter-version constraint.
set -uo pipefail

# rumdl/ruff: their user-global configs have no env-var override, so the synced
# ~/.claude copy has to land where each tool looks. (ruff's user config applies
# only when a project has no own ruff config.)
# Linux/macOS/WSL - first class: a symlink at the XDG location,
# ~/.config/<tool>/<tool>.toml -> the synced copy. Create ONLY if the target is
# absent - never clobber a real file, and a live symlink tracks the repo by itself.
# Windows (Git Bash, detected via APPDATA; WSL never sets it): the native tools
# read %APPDATA%/<tool>/ instead of ~/.config, and `ln -s` here silently COPIES,
# so a symlink can neither land right nor stay fresh (a frozen copy shipped a
# stale MD013 policy, found 2026-08-10) - refresh the copy whenever it differs.
for tool in rumdl ruff; do
  src="$HOME/.claude/$tool.toml"
  [ -f "$src" ] || continue
  if [ -n "${APPDATA:-}" ]; then
    if ! cmp -s "$src" "$APPDATA/$tool/$tool.toml" 2>/dev/null; then
      mkdir -p "$APPDATA/$tool"
      cp "$src" "$APPDATA/$tool/$tool.toml"
    fi
  elif [ ! -e "$HOME/.config/$tool/$tool.toml" ]; then
    mkdir -p "$HOME/.config/$tool"
    ln -s "$src" "$HOME/.config/$tool/$tool.toml"
  fi
done

exit 0
