# Ecosystem cleanup - status and plan

Long-task handoff. Resume from "Next up"; the phases are ordered by dependency, not priority.

Origin: a read-only audit of `~/.claude`, the five `~/Developer` repos, and the Windows clone
(2026-07-24). Findings are evidence-backed - each cites a file, line, and quote - and the ones that
drive work below are restated inline so this file stands alone.

## Decisions already made

Do not re-litigate these; they are settled with evidence.

- **Posture: curated prune, not rebuild.** The core (sync repo, merge driver, hooks, personal skills,
  permission mechanics, GitHub layer) audited healthy. The pain is concentrated in plugins, duplicated
  ownership, stale state, and accretion.
- **Model routing: Opus 5 is the default tier**, Fable escalates deliberately. Opus 5 shipped in
  v2.1.219 at half Fable's price; a same-prompt A/B at matched effort with no advisor spent 407.0K
  tokens (Opus 5) vs 407.9K (Fable) - equal work, half the price. Fable's documented niche is
  multi-sitting autonomous runs and genuinely ambiguous investigation.
- **Advisor: off on this machine.** A Fable main model rejects an Opus advisor, so the setting was
  inert on the main loop and only fired inside subagent runs. On an Opus 5 main it is a real choice -
  enable per-task if a second opinion is worth the uncached full-transcript read.
- **Superpowers: remove everywhere.** All 14 skills are covered by native features (plan mode,
  Workflow, EnterWorktree, `/review`), by the CLAUDE.md contract, or by the standalone `skill-creator`
  plugin. No extraction needed.
- **Specs: OpenSpec wins.** Already live in `diffusion-scratch` and cross-referenced to the behavior
  contract. Migrate `ollama-modelfiles` *after* the llamacpp migration lands - do not disturb PR #14.

## Done

**Phase 0 - this machine** (no repo edits):

- `/model opus` saved as default; `/advisor off`.
- Killed two bg workers idle since Jul 17 (one never did any work); removed
  `daemon-auth-status.json` + `daemon-auth-cooldown`, stale since Jul 20 despite auth recovering
  the same day.
- Reclaimed ~273M: `security/agent-sdk-venv` (278M, built by the no-longer-enabled security-guidance
  plugin) and 96 never-GC'd `security_warnings_state_*` files. `~/.claude` 520M -> 247M.

**Phase 1 - config repo**, on branch `audit/phase1-fixes` (two commits, not merged):

- `hooks/`: awk-guard now lexes per line (a command after a newline previously escaped the guard
  entirely); rumdl-md-check subtracts `old_string` so unchanged Edit context stops re-flagging
  pre-existing violations; both linters resolve via PATH with a `~/.local/bin` fallback and exit with
  a one-line install pointer instead of a traceback.
- `CLAUDE.md`: Delegation rewritten as the single owner of the model tiers, retiered for Opus 5;
  Writing cut to what the hooks do not already enforce; the false "(hook detects the break)" claim
  removed; `rules/lessons.md` folded into rule 4 and deleted.
- Deleted `agents/scout.md` (0 spawns in its lifetime - the harness auto-delegates search to the
  built-in Explore), `agents/mechanic.md` (2 spawns), and `skills/delegation/`.
- `rules/settings-scope.md`: `paths` narrowed to `**/.claude/settings*.json` - it was matching every
  VS Code `settings.json`.
- `README.md`: dropped the pointer to a nonexistent `InstructionsLoaded` hook.

## Next up

### Phase 1b - finish the config repo (same branch)

1. **Permissions** (`settings.json`; use the `auditing-permission-scope` skill). 138 allows -> ~110,
   42 denies -> ~24, equal or better coverage:
   - Delete `Bash(git add *)` and `Bash(git commit *)`. Together with the allowed `sync.sh push`
     they form a zero-prompt path to the remote, which contradicts the Git section's "offer the
     commit" / "push only on explicit request". The returned prompt *is* that offer.
   - Delete `Bash(curl -I *)` / `Bash(curl --head *)` - a HEAD request reaches any host with the full
     URL, bypassing the WebFetch domain allowlist.
   - Replace `Bash(nvidia-smi *)` with read-only forms (`-q`, `--query*`, `-L`, `dmon`, `topo`), then
     delete all 17 nvidia-smi denies - they are literal prefixes, so a reordered flag
     (`nvidia-smi -i 0 -pl 200`) slips past every one of them today.
   - `additionalDirectories`: `/tmp` -> `/tmp/claude-1000` (user-owned, mode 700). Confirm scratchpad
     access stays promptless in one session before committing.
   - Add `Read(~/.cache/huggingface/token)` (mode 644 on disk); widen the `.env` denies to `.env*`.
   - Drop ~20 dead allows: duplicates of the built-in read-only set, exact+wildcard twins, and the
     Windows-era `winget` / `where.exe` rules.
   - Move the 8 single-project research WebFetch domains to the owning repo's settings.
   - *Verify*: JSON parses; run one ordinary session and note which prompts return. Expect prompts at
     task wrap-up (commit) and on non-query nvidia-smi.
2. **Sync noise** (`sync.sh`). Auto-save commits are 149 of 237 (63%) and bury labeled work. In
   `commit_pending`: if HEAD's subject starts with `auto-save <hostname>` **and** HEAD is not
   contained in `@{u}`, use `git commit --amend`. Caps noise at one autosave per push cycle, never
   rewrites pushed history.
   - *Verify*: two consecutive SessionEnd saves produce one commit; a save after a push produces a
     new one.
3. **Pending-push visibility.** `save` always exits 0 by design, so a failed commit or a multi-day
   unpushed backlog is invisible in-session (a 6-day backlog and a swallowed lock-race are both in
   `sync.log`). Surface the ahead-count in the statusline, which already parses state cheaply.
4. **Merge**: review the branch, merge to master, restart one session, then `/sync-push`.

### Phase 2 - plugins

Most "enabled" plugins never load where the work happens: 8 of 9 `enabledPlugins: true` entries are
installed only at project scope for `/mnt/c/Users/mawil` (the Windows home), verified live for
context7. Meanwhile superpowers loads *despite* its global `false`, because two repos re-enable it.

- Remove `enabledPlugins` entries that cannot load here: claude-code-setup, claude-md-management,
  code-review, commit-commands, context7, feature-dev, pyright-lsp, skill-creator.
- Uninstall superpowers (both install records) and delete the `enabledPlugins` blocks from
  `ollama-modelfiles/.claude/settings.json` and `diffusion-scratch/.claude/settings.json`.
- hookify: it loads on every session and spawns python3 on four hook events, but no
  `hookify.*.local.md` rule file exists anywhere - it evaluates nothing. Write the rules or disable it.
- Optional reinstalls at **user** scope if wanted here: `skill-creator` (its recorded install path is
  orphaned), `pyright-lsp` (needs `npm install -g pyright` first).
- Uninstall the four disabled life-sciences plugins and drop the marketplace (~80M).
- *Verify*: skill listing and `claude mcp list` before/after; one session in `ollama-modelfiles`.

### Phase 3 - Windows surface (order matters)

Native Windows has no real Python - `python3` is the 2-byte Store alias stub - so every hook has
failed there since Jun 27 (2,720 `hook_non_blocking_error` events) and the settings merge driver
cannot run. The clone is also 17 commits behind with no automatic pull anywhere.

1. Install real Python 3 on Windows. This revives the five hooks and the merge driver at once.
2. Then `bash ~/.claude/sync.sh pull` there - the tree is clean and at `origin/master`, so it is a
   conflict-free fast-forward. Do this *after* step 1, or the pull adds a third dead hook.
3. Then decide a SessionStart auto-pull hook. Verify git-over-SSH authenticates from a Windows hook
   context first - `sync.sh` exports a Linux-style `SSH_AUTH_SOCK`.
4. Install rumdl there if `.md` work resumes on that side.

### Phase 4 - repos

- Migrate `ollama-modelfiles` `specs/` to OpenSpec once the llamacpp migration lands.
- Prune `ollama-modelfiles/.claude/settings.local.json` (6KB, ~130 grants): drop sha256-pinned curls,
  `echo "exit=$?"` one-shots, dead `mcp__plugin_context7_*` grants, and `Skill()` grants for things
  that are Workflows (they never match). Keep the reusable globs.
- Pick one owner for deep research: the repo ships both superpowers and a hand-rolled
  `deep-research.js` ported from a superpowers workflow. Dropping superpowers (Phase 2) settles it -
  delete the disabled, stale one-shot research workflow too.
- Delete `~/Developer/claude-code-quarantine`: one 77-byte grant for `Skill(deep-research)`, a
  capability that is a Workflow defined in another repo. Not a git repo; untouched for a month.
- Remove the stale `scheduled_tasks.lock` (dead PID, a month old) and the empty `worktrees/` dir.
- Track `benchmarking_molecular_models/.claude/settings.json` - its shareable project settings live
  only on this machine.

## Open

- The two >120-col lines in `rules/settings-scope.md` predate this work and were left alone per
  "leave untouched text unrewrapped". They will re-nag on any full-file Write. Fix or annotate when
  next editing that file for its own reasons.
- The API-level advisor table (`claude-api` skill) says a Fable executor accepts an Opus 5 advisor;
  the live Claude Code doc says it rejects one. Claude Code's behavior is what governs here.
- No published subscription multiplier for Fable exists. What is published: on Max, Fable is capped
  at 50% of weekly limits and "uses them faster". The 2x figure is API pricing, not a metering rule.

## Working notes

- Config edits go on a branch in a worktree; the working tree *is* the live config, so never edit
  `~/.claude` directly for anything under review.
- Pull with the app idle - a pull rewrites live config under any running session. Restart if
  `settings.json` changed.
- Deletions of runtime state (daemon files, venvs, plugin caches) are one-way. Confirm before each.
