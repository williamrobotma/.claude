# Hand-off: claude-local unification (Windows session, 2026-08-10)

For the WSL2 session. Context: plugin-disabling was made a claude-local feature, and claude-local itself became one synced script.

## Done

- New synced launcher `~/.claude/bin/claude-local` (bash, executable, allowlisted in `.gitignore`): a port of the WSL `~/.bashrc` fn with these changes.
  - Lane menu is built from the live router (`GET /v1/models` on 11433, read-only) instead of the local `models.ini` path, and shows each lane's loaded/sleeping/unloaded status.
  - Everything else kept: C-collation sort, Enter re-picks `~/.config/claude-local.last`, non-TTY reuses last or fails with the list, non-numeric input is a verbatim lane name, all claude args pass through, B6 fix (ANTHROPIC_MODEL + 3 tier vars + CLAUDE_CODE_SUBAGENT_MODEL), `=VALUE`-form flags.
  - New: every plugin disabled per-session via `claude --settings '{"enabledPlugins": {<each key>: false}}'`, generated from `settings.json` at launch so it never goes stale. Verified: a `--settings` plugin override beats the settings.json value (CLI-arg precedence), and a launch through the script showed `"plugins":[]` in the init event.
  - Web-search MCP wiring (`--disallowedTools=WebSearch`, `--mcp-config`, sourcing `~/.config/claude-local.env`) is gated on `~/.config/claude-local.mcp.json` existing - present in WSL, absent on Windows/macOS.
- Windows shim `~/bin/claude-local.ps1` (machine-local, untracked) is now just `bash "$HOME/.claude/bin/claude-local" @args`; its stale hardcoded env (Ollama-era model name, token) is gone.
- `settings.json` `enabledPlugins` reverted to the upstream all-enabled values - the global disable was a workaround this replaces, and it never reaches other machines' history.

## Decided

- Plugin state stays synced and enabled in `settings.json`; claude-local sessions disable plugins per-session via the flag. `merge-settings.py` PER_MACHINE was deliberately NOT extended.
- `ANTHROPIC_BASE_URL=http://127.0.0.1:11433`, hardcoded, no `/v1`: claude-local rides `Anthropic /v1/messages` (ollama-modelfiles `docs/architecture.md`); `11433/v1` is the OpenAI-client form.
- Auth token: `local-router-dummy` (the WSL fn's value; the router checks nothing).
- Proxy URL/model are not parameters of the synced script: URL is hardcoded, model comes from the menu.
- claude-local is opt-in per machine: the synced script is inert until a machine adds its own shim (PS profile fn on Windows, bashrc fn in WSL). Nothing puts it on PATH, `provision.sh` is untouched, and most machines will simply never call it; calling it without the router fails in one visible line.

## WSL next steps

1. `bash ~/.claude/sync.sh pull` to receive `bin/claude-local`.
2. Replace the `~/.bashrc` `claude-local()` fn (lines ~161-213) with: `claude-local() { "$HOME/.claude/bin/claude-local" "$@"; }`.
3. Verify against the live router (Windows could not - router down, GPU blocked):
   - a real interactive launch end-to-end (menu, lane pick, session works);
   - UNVERIFIED: whether `/v1/models` lists `models.ini` aliases alongside ids - if not, aliases are reachable only via the verbatim escape hatch; decide if the menu should merge them in.
4. Update ollama-modelfiles `CLAUDE.md#claude-local` (feat/llamacpp-migration): the fn is now a shim over the synced script, and the menu source is the live router, not `models.ini`.
