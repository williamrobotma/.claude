# Ecosystem cleanup - status and plan

Long-task handoff. Resume from "Next up"; the phases are ordered by dependency, not priority.

This file is AI-written - every commit on it carries `Co-Authored-By: Claude Opus 5`.

- CLAUDE.md rule 2 therefore applies to the file itself: it is a pointer, never ground truth.
- Origin: a read-only audit of `~/.claude`, the five `~/Developer` repos, and the Windows clone (2026-07-24).
- A verification pass on 2026-07-25 re-checked most claims at the source. Corrections are folded in below.
- Claims that pass unchecked are tagged UNVERIFIED. See "Verification status" for what was never reached.

## Orchestration

You are the orchestrator.

- **Consent model, set by the user on 2026-07-25: propose the diff, then wait for approval, once per phase.**
  - Show the change and its verification command; apply only after the user approves.
  - This replaces the former "Everything else proceeds without asking" clause.
  - That clause was written into this doc by an AI session (63643d1), not granted by the user. It is void.
  - Editing on a review branch is included. The branch is not a consent gate by itself.
- **Sequencing.** Phase 1b and Phase 2 are the config work. Phase 4 waits on Phase 2.
  - Both edit `ollama-modelfiles/.claude/settings*.json`, and Phase 2 decides whether that file survives at all.
  - Phase 3 is user-driven on the Windows machine. Do not run it as a parallel agent - it stops at its first action.
- **Price before delegating**, per the CLAUDE.md Delegation tiers: state agent count x model up front.
  - A count, a `stat`, a single file read is inline work. No agent.
  - Phase 1b step 3 and the Phase 4 lock/dir removals are single-file edits; an agent only adds a handoff.
  - The live contract still requires the `delegation` skill before any spawn, until this branch merges.
- **Stop and ask before**: merging to master, uninstalling a plugin, deleting any file or directory,
  editing a live `.claude/settings*.json` outside this worktree, anything on the Windows machine, any `git push`.
  - Phases 2 and 4 edit tracked settings on other repos' main branches. The "it is only a branch" argument
    does not cover them.
- **The orchestrator presents every gated diff.** A subagent's approval is not the user's approval.
- **Report per phase**: what changed, the verification command and its output, and what you left.
- **Do not merge `audit/phase1-fixes`.** It is under review; base new config work on it, not on master.

## Decisions already made

Recorded, not immune. Each carries the strength of its own evidence; re-open any of them at the source.

- **Posture: curated prune.** Chosen by the user on 2026-07-25, closing the former "Open" blocker.
  - Fix defects, delete what demonstrably does not earn its place, keep what audited healthy.
  - The rejected alternative was a ruthless-minimal core: drop hookify outright, cut CLAUDE.md harder,
    skip the optional plugin reinstalls.
  - Two items still resolve inside this posture, because the evidence moved: see hookify in Phase 2.
- **Goals: all four axes matter** - fewer moving parts, less in-session friction, lower context load, correctness.
  - Set by the user on 2026-07-25. No phase is dropped for being low-value on one axis.
- **Git allows stay.** `Bash(git add *)`, `Bash(git commit *)` and the `sync.sh push` allow are all kept.
  - User decision, 2026-07-25: the guarantee is the CLAUDE.md Git rule, not the permission system.
  - This deletes the former first bullet of the permissions prune and moves the allow target to ~112.
  - Note `ollama-modelfiles/.claude/settings.local.json` also grants `Bash(git push *)`, which global lacks.
- **Model routing: Opus 5 is the default tier**, Fable escalates deliberately.
  - Opus 5 shipped in v2.1.219 at half Fable's price. UNVERIFIED - no pricing source was checked.
  - The supporting A/B (407.0K tokens Opus 5 vs 407.9K Fable) is **N=1 with no recoverable provenance**.
  - "Equal token count" was read as "equal work". That is a judgment, and it was presented as measurement.
  - The decision is cheap to reverse with `/model`, so it does not need better evidence to stand.
- **Advisor: off on this machine.** Live state confirmed: `advisorModel` is absent from `settings.json`.
  - The rationale (a Fable main model rejects an Opus advisor) is UNVERIFIED against the Claude Code docs.
  - On an Opus 5 main it is a real choice - enable per-task if a second opinion is worth the full-transcript read.
- **Specs: OpenSpec wins.** Confirmed live in `diffusion-scratch`: `openspec/config.yaml:1 schema: spec-driven`,
  23 tracked files, CLI 1.6.0 installed, an active change under `openspec/changes/overhaul/`.
  - It has no `openspec/specs/` at all, so "migrate" means the `changes/` + `config.yaml` + tagging convention.
- **Superpowers: remove, but gated.** The 14-skill count is confirmed; the coverage verdict is not.
  - `writing-skills` has no installed replacement - `skill-creator`'s recorded install path is orphaned.
  - Three more (`finishing-a-development-branch`, `dispatching-parallel-agents`, `systematic-debugging`)
    map to a one-line rule or to nothing named.
  - It is live in exactly one place, `ollama-modelfiles`. The `diffusion-scratch` entry is already inert.
  - Treat as a one-way deletion needing approval, not a closed decision.

## Done

**Phase 0 - this machine** (no repo edits):

- `/model opus` saved as default; `/advisor off`. Confirmed in `37a9a97`: `-"model": "fable"` / `+"model": "opus"`,
  and `-"advisorModel": "opus"` with no replacement.
- Killed two bg workers idle since Jul 17. Confirmed at `daemon.log:585-586`, both `state: stopped`.
  - Nothing was orphaned. `daemon.lock` is **live**, not stale - pid 1739273 is running.
- Removed `daemon-auth-status.json` + `daemon-auth-cooldown`. Absence confirmed; the Jul 20 story checks out.
  - This was a tidy, not a fix. The next headless re-auth recreates both files and they go stale the same way.
- Reclaimed disk: `security/agent-sdk-venv` (278M) and 96 `security_warnings_state_*` files.
  - "never-GC'd" is **wrong**. A 30-day GC exists (`session_state.py:49`, called at 10% probability per hook run).
  - The files survived because the plugin stopped running on 2026-07-01, so the GC never fired.
  - `~/.claude` is 253M today and drifting up with every session. Do not plan against a fixed number.
  - `security/log.txt` (155KB) and `.sdk_bootstrap_spawned` were left behind. Both inert.

**Phase 1 - config repo**, on branch `audit/phase1-fixes`: five commits, of which two carry the config work.

- `f1039ae` (hooks) and `e759536` (instructions) are the work below. `f782c14`, `63643d1`, `d22273b` are this doc.
- **The branch is one commit behind master** (`37a9a97`, Phase 0's autosave). This matters - see Phase 1b step 1.
- **None of it is live.** `settings.json` registers hooks at `$HOME/.claude/hooks/`, which is still master
  byte-for-byte. No Phase 1 fix can be verified by running a session until the branch merges.

Hooks:

- awk-guard now lexes per line. The newline bypass is closed, verified end-to-end.
  - **Regression, undocumented until now**: a backslash-continuation now raises `ValueError`, swallowed at
    `hooks/awk-guard.py:57-58`, so `cat f |\` + newline + `awk '...'` falls through where master denied it.
  - Bounded, not silent: no awk allow rule exists and `defaultMode` is `default`, so fall-through means a prompt.
  - New false deny: a heredoc body that merely mentions awk is now denied.
  - Still open and not disclaimed: `/usr/bin/awk` (absolute path) and backtick substitution both bypass it.
- rumdl-md-check subtracts `old_string`, so unchanged Edit context stops re-flagging. Verified.
  - Known limit: the subtraction is text-based, not positional, so duplicating an existing >120-col line is exempt.
- Both linters resolve via PATH with a `~/.local/bin` fallback and print a one-line install pointer.
  - The **exit code did not change** (1 before, 1 after). Only exit 2 reaches the model, so a missing linter
    still fails open toward the agent: loud to the user, silent to Claude.
- **Fourth change, not previously listed**: `rumdl-md-check.py:12-15` added a `json.load` try/except that
  exits 0 on malformed stdin. That is the silent-swallow `rules/python.md:12` warns against. Drop or document it.

Instructions:

- `CLAUDE.md`: Delegation is now the single owner of the model tiers, retiered for Opus 5. Verified - no competing
  tier statement survives in any tracked file.
  - Writing was cut to what the hooks enforce. Not quite lossless: the 120 figure and the splice rule went with it.
  - The false "(hook detects the break)" claim is gone, and it really was false.
  - The file **grew** by 494 bytes. Netted against the deleted `rules/lessons.md`, always-loaded context is flat.
- `rules/lessons.md` folded into rule 4 and deleted. No information lost.
- Deleted `agents/scout.md` (0 spawns), `agents/mechanic.md` (2 spawns), `skills/delegation/`.
  - Spawn counts reproduced exactly across 761 transcripts. Keep the deletions.
  - The stated cause ("the harness auto-delegates search to the built-in Explore") is the doc's own inference.
  - **Dangling reference to fix before merge**: `skills/pr-review-sweep/SKILL.md:21` still says
    "Pick each subagent's model with the `delegation` skill."
- `rules/settings-scope.md`: `paths` narrowed. The doc misquoted its own change - there is no `settings*.json`
  glob. It is two exact patterns: `**/.claude/settings.json` and `**/.claude/settings.local.json`.
- `README.md`: dropped the `InstructionsLoaded` hook pointer. **This was wrong - the hook is real.**
  - 27 references in the v2.1.219 binary, including the payload builder. Restore the pointer.
  - It is also the one read-only probe that would settle the `settings-scope.md` glob claim empirically.
- `.gitignore`: added `!docs/` and `!docs/*.md` in `f782c14`. Previously undocumented here.

## Next up

### Phase 1b - finish the config repo (same branch)

1. **Permissions** (`settings.json`; use the `auditing-permission-scope` skill). Gated: propose the full diff and
   the prompts it will cost. 138 allows -> ~112, 42 denies -> ~24. Baseline counts confirmed live.
   - **Do this first: bring the branch up to master, or hand-edit only the `permissions` block.**
     The branch's `settings.json` predates Phase 0. A wholesale rewrite reintroduces `"model": "fable"` and
     `"advisorModel": "opus"` and silently undoes Phase 0. The merge driver is the only thing that would catch it.
   - Delete `Bash(curl -I *)` / `Bash(curl --head *)` - a HEAD request reaches any host with the full URL,
     bypassing the WebFetch domain allowlist. UNVERIFIED: check whether other allowed curl forms do the same.
   - Replace `Bash(nvidia-smi *)` with read-only forms (`-q`, `--query*`, `-L`, `dmon`, `topo`), then delete the
     17 nvidia-smi denies - they are literal prefixes, so a reordered flag slips past all of them.
     UNVERIFIED: the bypass was never demonstrated, and whether the risky calls need root was never checked.
   - `additionalDirectories`: `/tmp` -> `/tmp/claude-1000`. UNVERIFIED: owner and mode were never confirmed.
   - Add `Read(~/.cache/huggingface/token)`; widen the `.env` denies to `.env*`. UNVERIFIED: file and mode.
   - Drop the dead allows: duplicates of the built-in read-only set, exact+wildcard twins, and the Windows-era
     `winget` / `where.exe` rules. UNVERIFIED: never enumerated. Expect fewer than the ~20 claimed.
   - Move the 8 single-project research WebFetch domains to the owning repo's settings. UNVERIFIED: not listed.
   - *Verify*: JSON parses; `"model"` is still `opus` and `advisorModel` still absent; run one ordinary session
     and note which prompts return. Expect a prompt on non-query nvidia-smi.
2. **Sync noise** (`sync.sh`). Auto-save commits are 149 of 238 on master (63%).
   - The premise "buries labeled work" is a judgment, not a measurement. Weigh the read-time fix first.
   - **Cheapest option, zero lines in `sync.sh`**: read history with
     `git log --oneline --invert-grep --grep='^auto-save '`. This solves the stated symptom with no rewriting.
   - If collapsing is still wanted, do it in `push`, not `save` - the user is present and the commits are
     provably unpushed.
   - If it stays in `save`, the amend must be `git commit --amend --no-edit`. **Plain `--amend` opens an editor**;
     SessionEnd has no TTY and the failure is swallowed, so autosave would silently stop committing.
   - Gate on the `ahead` count `sync.sh:63` already computes, plus the subject prefix, plus no `.git/MERGE_HEAD`.
   - Correct the claim before implementing: it caps noise at one autosave **per consecutive run**, not per push
     cycle. On observed history one cycle goes 9 -> 3, not 9 -> 1.
   - "Never rewrites pushed history" is an assumption, not a guarantee: `save` never fetches, and `@{u}` is two
     days stale right now. Staleness errs safe, but default to no-amend when `@{u}` fails to resolve.
   - `sync.sh` has no lock. Two races are already in `sync.log` (`:125` index.lock, `:208` HEAD ref CAS).
     One `flock` on `$repo/.git/sync.lock` around `commit_pending` closes both, pre-existing and new.
   - Cost to accept: two sessions' snapshots collapse into one commit, under the earlier one's author date,
     so "which session changed this" stops being answerable.
   - *Verify*: two consecutive SessionEnd saves produce one commit; a save after a push produces a new one;
     a save while `MERGE_HEAD` exists still commits; two overlapping saves lose nothing.
3. **Pending-push visibility.** `save` always exits 0 by design, so a failed commit or a multi-day backlog is
   invisible in-session. Confirmed: a ~5.7-day backlog and two swallowed races are in `sync.log`.
   - The work is **surfacing, not computing**: `sync.sh:63` already produces the exact number.
   - "The statusline already parses state cheaply" is **wrong**. It has one git call, `$cwd`-scoped, no caching.
     An ahead-count needs a new subprocess hard-coded to `-C "$HOME/.claude"`.
   - Cost is fine either way: +1.79ms on a 35.27ms render, at `refreshInterval: 30`.
   - **Recommended surface: a SessionStart note, not the statusline.** It fires once, when the backlog is
     actionable, costs nothing per render, and reuses `sync.sh`'s own computation.
   - Needs a threshold whichever surface wins: `ahead > 0` is the steady state (220 of 261 log lines), so an
     unconditional indicator says nothing. Follow the existing rate-limit band at `statusline-command.sh:105-106`.
   - Two traps: do not reuse `$cwd`; and do not collapse "no upstream" to 0 - this very worktree has no upstream,
     so `2>/dev/null || echo 0` would report "nothing pending" while 2 commits sit unpushed.
   - An ahead-count does **not** cover the failed-commit symptom - a failed commit leaves the count flat.
     That needs a dirty-tree indicator or a failure note in `commit_pending`.
   - *Verify*: with 2 unpushed commits the indicator shows 2; with 0 it is absent; with no upstream it shows a
     distinct marker rather than 0.
4. **Merge**: fix the `pr-review-sweep` dangling reference and decide the awk-guard regression first.
   Then review the branch, merge to master, restart one session, then `/sync-push`.

### Phase 2 - plugins

Most "enabled" plugins never load where the work happens: 9 `enabledPlugins: true` entries exist, and 8 are
installed only at project scope for `/mnt/c/Users/mawil` (the Windows home).

- Remove the `enabledPlugins` entries that cannot load here: claude-code-setup, claude-md-management, code-review,
  commit-commands, context7, feature-dev, pyright-lsp, skill-creator.
  - The enumeration is confirmed. The **inference is not** - "cannot load here" was checked only for context7.
  - Verify per plugin with `claude plugin list` in a real cwd before deleting its entry. It prints
    an explicit enabled/failed-to-load status per record. Removing a live capability is the failure mode here.
  - Check `/code-review` before removing that entry - it may be a built-in rather than the plugin.
- Uninstall superpowers (both install records, 3.9M) and remove the superpowers line from
  `ollama-modelfiles/.claude/settings.json` and `diffusion-scratch/.claude/settings.json`.
  - **Delete only the superpowers line, not the block.** `diffusion-scratch`'s block holds 7 entries; deleting it
    removes feature-dev, four life-sciences plugins and security-guidance as collateral.
  - `ollama-modelfiles`'s file *is* the block - decide whether it becomes `{}` or is deleted, before Phase 4.
  - The real win is one SessionStart hook and 14 skill descriptions, not disk.
- hookify: it loads every session and spawns python3 on four hook events, but no `hookify.*.local.md` rule file
  exists anywhere - it evaluates nothing, confirmed by execution returning `{}`.
  - Measured cost of keeping it: **+88ms per tool call** (PreToolUse 53ms + PostToolUse 35ms) for a guaranteed
    `{}`, plus ~124 tokens and 5 skill-listing slots in every context, plus 2.9M.
  - For scale, the user's own five hooks total 171ms per tool call, so this is a 51% increase.
  - The rule glob is cwd-relative (`.claude/hookify.*.local.md`), so "write the rules" can only ever give
    per-project coverage, never a global guardrail.
  - **Recommend disable**, even under curated prune: the component provably does nothing and the cost is measured.
    It is fully reversible - `settings.json` is tracked and the marketplace is a git URL.
- Optional reinstalls at **user** scope: `pyright-lsp` costs 0 always-on tokens and 28K, so it is a plain
  want/do-not-want question (needs `pyright` installed first; it is not on PATH).
  - Skip `skill-creator` unless the superpowers `writing-skills` gap matters - it costs 117 always-on tokens.
- Uninstall the four disabled life-sciences plugins and drop the marketplace. 77.8MB confirmed
  (marketplace 40.2MB + cache 41.4MB). Dropping the marketplace alone reclaims less than half.
  - **They are only disabled at user scope.** All four are enabled at project scope in `diffusion-scratch`
    and load there, including the Consensus and PubMed MCP servers. Confirm with the user before uninstalling.
- **Add `security-guidance` to this phase.** It is still installed and enabled in `diffusion-scratch`, and one run
  rebuilds the 278M venv and restarts `security_warnings_state_*` accumulation that Phase 0 cleaned up.
- **Also unaddressed**: `code-simplifier` is installed at user scope but absent from `enabledPlugins`; seven
  account-level `claude.ai` MCP connectors are live and unmentioned, two of which (Context7, PubMed) duplicate
  plugin function - an argument for removal the doc never made.
- *Verify*: `claude plugin list` per repo before/after, and one session in `ollama-modelfiles`.
  - **Not `claude mcp list`** - it returns byte-identical output before and after every action outside
    `diffusion-scratch`, so it cannot verify anything.

### Phase 3 - Windows surface (order matters)

**Every premise in this phase is UNVERIFIED** - the verification pass was stopped before reaching it. The user
confirmed on 2026-07-25 that they work on Windows regularly, so this is real work, but check the premises first.

Claimed, unchecked: native Windows has no real Python (`python3` is the 2-byte Store alias stub), so every hook
has failed since Jun 27 (2,720 `hook_non_blocking_error` events) and the settings merge driver cannot run. The
clone is also 17 commits behind with no automatic pull anywhere.

1. **Before installing anything**: confirm the hooks would actually resolve on Windows once python3 exists.
   They are registered as `python3 $HOME/.claude/hooks/*.py` - check that `$HOME`, the path forms and the
   shebangs resolve under native Windows rather than assuming WSL paths. If they would still break, the install
   buys nothing and the honest options are to stop syncing hooks there or to retire the clone.
   - Also search for an existing real Python before concluding there is none: `py.exe`,
     `AppData/Local/Programs/Python`, conda/miniforge, uv.
2. Then install real Python 3 on Windows, if step 1 says it helps. This revives the hooks and the merge driver.
3. Then `bash ~/.claude/sync.sh pull` there. Do this *after* the install, or the pull adds another dead hook.
   Confirm the tree is clean and a fast-forward is actually possible first.
4. Leave the pull manual. A SessionStart auto-pull fires exactly when other sessions may be live, which this
   doc's own working note forbids. Add it only if the user asks.
5. Install rumdl there if `.md` work resumes on that side.

### Phase 4 - repos

- Migrate `ollama-modelfiles` `specs/` to OpenSpec once the llamacpp migration lands.
  - **The stated blocker is gone**: PR #14 is MERGED (2026-07-23) and no PR is open. It was the *plan* PR,
    not the migration.
  - The real gate: `specs/llamacpp-migration/tasks.md` has zero completed items. Do not start yet.
- Prune `ollama-modelfiles/.claude/settings.local.json`. It is 6083 bytes with **112 allows** (plus 1
  `skillOverrides` entry), not ~130 - and it is git-ignored and mutating, so snapshot it and report your own
  before/after rather than trusting any count here.
  - Drop the 2 sha256-pinned curls and the exit-code one-shots. There are **3 forms** of the latter, not 1 -
    grepping the single literal `echo "exit=$?"` leaves two behind.
  - Drop the dead `mcp__plugin_context7_*` grants.
  - Drop `Skill(deep-research)` and `Skill(deep-research-models)` - both name Workflows, so they never match.
    **Keep `Skill(claude-api)`** - that one is a real skill.
  - "Keep the reusable globs" is an instruction with no test attached. Treat this prune like Phase 1b step 1:
    present the diff. `Bash(cd *)`, `Bash(env)`, and a curl that forges a Docker registry Accept header are all
    in the file and unmentioned.
- Deep research has one owner already. The claimed superpowers overlap is **refuted**: `deep-research.js:9` says
  "Ported from bughunter architecture", and superpowers ships no workflows at all.
  - So there is no "pick one owner" decision. `Workflow(deep-research)` is the sole owner.
  - The stale one-shot to delete is `.claude/workflows/openwebui-ollama-env-research.js` - the only one with a
    `skillOverrides: off`. The case for deleting it is staleness, not de-duplication.
  - `deep-research-models.js` is equally one-shot (its angles hardcode "as of July 2026"). Decide it explicitly.
- Delete `~/Developer/claude-code-quarantine`. The whole directory is 2 entries: one 77-byte
  `settings.local.json` granting `Skill(deep-research)`, and its parent. Not a git repo. Safe.
  - Correct the rationale: the directory node is **15 days** old, not a month. The certainty rests on the
    inventory, not the age.
- Remove the stale `scheduled_tasks.lock` and the empty `worktrees/` dir. **Both are in `ollama-modelfiles`** -
  the path was previously unstated.
  - Lock confirmed dead: pid 3706081 does not exist, mtime 2026-06-25.
  - **Hazard**: `~/.claude/.git/worktrees` also matches "the empty worktrees dir" and is **not** empty - it holds
    the live registration for this review worktree. State the full path in any instruction.
- Track `benchmarking_molecular_models/.claude/settings.json` - 170 bytes, two repo-relative grants, confirmed
  untracked and not ignored, and genuinely shareable.
  - The repo is on branch `non-clamp` with a dirty tree. Decide the target branch before `git add`.
- `llama.cpp` has no `.claude` directory at all and needs nothing. Noted so a reader auditing "the five repos"
  does not go looking.

## Verification status

A 2026-07-25 pass checked the doc's claims at the source. It was stopped early on cost grounds, so coverage is
uneven and named here rather than assumed.

- **Checked, corrections folded in above**: Phase 0, Phase 1 hooks, Phase 1 instructions, Phase 1b steps 2 and 3,
  Phase 2, Phase 4, the posture fork, and intent-consistency against CLAUDE.md.
- **Never reached, still inherited from the original audit**: the Phase 1b step 1 permissions detail (beyond the
  138/42 baseline, which is confirmed), all of Phase 3, and the pricing and advisor-behavior claims under
  "Decisions already made".
- Every number in this doc that is not tagged UNVERIFIED has a file, line, and quote behind it in the pass.
- Provenance caveat on the measured costs: hook timings are 20 reps on one WSL2 host, single run. Ordering is
  robust; absolute values are host-specific. Token figures are chars/4 estimates.

## Open

- The two >120-col lines in `rules/settings-scope.md` predate this work and were left alone per "leave untouched
  text unrewrapped". They will re-nag on any full-file Write. Fix or annotate when next editing that file.
- `statusline-command.sh:101` embeds a literal arrow glyph, against the CLAUDE.md Writing rule. Phase 1b step 3
  edits that file, so that is the natural moment - or leave it and note it.
- The API-level advisor table (`claude-api` skill) says a Fable executor accepts an Opus 5 advisor; the live
  Claude Code doc reportedly says it rejects one. Neither was checked. Claude Code's behavior governs here.
- No published subscription multiplier for Fable exists. What is published: on Max, Fable is capped at 50% of
  weekly limits and "uses them faster". The 2x figure is API pricing, not a metering rule. UNVERIFIED.
- `~/.claude/projects/` is 138M of a 253M tree - the largest consumer and the only one actively growing, 99M of
  it one repo's transcripts. No phase touches it. The missing lever is an explicit `cleanupPeriodDays`.
- Nothing in this plan is gated on a Fable escalation. Phase 1b step 4 (review, then merge) is the sign-off the
  live delegation skill assigns to Fable. Decide deliberately rather than by omission.

## Working notes

- Config edits go on a branch in a worktree; the working tree *is* the live config, so never edit `~/.claude`
  directly for anything under review.
- The branch is behind master by Phase 0's autosave. Rebase or merge before rewriting any whole file.
- Pull with the app idle - a pull rewrites live config under any running session. Restart if `settings.json`
  changed.
- Deletions of runtime state (daemon files, venvs, plugin caches) are one-way. Confirm before each.
- `workflowSizeGuideline` is unset, so dynamic workflows default to a "fewer than 15 agents" guideline. It is
  advisory only - nothing enforces it. Set it to `"small"` (<5) in `settings.json` if a harder default is wanted.
