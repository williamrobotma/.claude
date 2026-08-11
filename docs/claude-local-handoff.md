# Hand-off: claude-local unification (Windows session, 2026-08-10)

For the WSL2 session: plugin-disabling became a claude-local feature, and claude-local became one synced script.

Update 2026-08-11: a later session rewrote `bin/claude-local` against the live router.

- The menu now lists aliases from `/v1/models` (marked `alias -> <id>`).
- The status parse matches the real response shape.
- The canonical spec moved to ollama-modelfiles `AGENTS.md#claude-local`.
- Step 3 below is resolved by that work; the Done section describes the original port, superseded in those details.

## Done

- New synced launcher `~/.claude/bin/claude-local` (bash, executable, allowlisted in `.gitignore`).
  - A port of the WSL `~/.bashrc` fn with the changes below.
  - Lane menu is built from the live router (`GET /v1/models` on 11433, read-only), not the local `models.ini` path.
    - The menu shows each lane's loaded/sleeping/unloaded status.
  - Everything else kept: menu sort and pick semantics, last-lane recall, arg pass-through, `=VALUE`-form flags.
    - B6 fix kept too: ANTHROPIC_MODEL + 3 tier vars + CLAUDE_CODE_SUBAGENT_MODEL, all set to the lane.
  - New: plugins off per-session via `claude --settings='{"enabledPlugins": {<each key>: false}}'`.
    - The override is generated at launch from user `settings.json`, so it never goes stale.
    - Scope: plugins enabled only in a project's `.claude/settings*.json` are NOT covered.
    - Verified: a `--settings` plugin override beats the settings.json value (CLI-arg precedence);
      a launch through the script showed `"plugins":[]` in the init event.
  - Web-search MCP wiring is gated on `~/.config/claude-local.mcp.json` existing - present in WSL only.
    - The wiring: `--disallowedTools=WebSearch`, `--mcp-config`, sourcing `~/.config/claude-local.env`.
- Windows shim `~/bin/claude-local.ps1` (machine-local, untracked) now execs the script via Git Bash's full path.
  - Its stale hardcoded env (Ollama-era model name, token) is gone.
  - Bare `bash` in PowerShell resolves to the WSL launcher and breaks - hence the full path.
- `settings.json` `enabledPlugins` reverted to the upstream values: the 7 plugins this machine had turned off are back on.
  - github, hookify, superpowers, and the life-sciences set stay false, as upstream had them.
  - The global disable was a workaround this replaces; it never reaches other machines' history.

## Decided

- Plugin state stays synced and enabled in `settings.json`; claude-local sessions disable plugins via the flag.
  - `merge-settings.py` PER_MACHINE was deliberately NOT extended.
- `ANTHROPIC_BASE_URL=http://127.0.0.1:11433`, hardcoded, no `/v1` (ollama-modelfiles `docs/architecture.md`).
  - claude-local rides `Anthropic /v1/messages`; `11433/v1` is the OpenAI-client form.
- Auth token: `local-router-dummy` (the WSL fn's value; the router checks nothing).
- Proxy URL/model are not parameters of the synced script: URL is hardcoded, model comes from the menu.
- claude-local is opt-in per machine: the synced script is inert until a machine adds its own shim.
  - Shims today: a PS profile fn on Windows, the bashrc fn in WSL.
  - Nothing puts it on PATH and no provisioning step installs it; most machines will simply never call it.
  - Calling it without the router fails in one visible line.

## WSL next steps

1. `bash ~/.claude/sync.sh pull` to receive `bin/claude-local`.
2. Replace the `~/.bashrc` `claude-local()` fn with: `claude-local() { "$HOME/.claude/bin/claude-local" "$@"; }`.
   - The old fn also has a menu bug the script fixes: pick `00` indexes `-1`, silently selecting the last lane.
3. DONE (2026-08-11 rewrite): live-router verification; `/v1/models` does list aliases and the menu shows them.
4. Update the ollama-modelfiles claude-local spec (`AGENTS.md#claude-local`, feat/llamacpp-migration):
   the fn is a shim over the synced script, and the menu source is the live router, not `models.ini`.
