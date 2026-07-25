# Ecosystem cleanup - status and plan

Long-task handoff. Resume from "Next up"; the phases are ordered by dependency, not priority.

This file is AI-written - every commit on it carries `Co-Authored-By: Claude Opus 5`.

- CLAUDE.md rule 2 therefore applies to the file itself: it is a pointer, never ground truth.
- Origin: a read-only audit of `~/.claude`, the five `~/Developer` repos, and the Windows clone (2026-07-24).
- A verification pass on 2026-07-25 re-checked most claims at the source. Corrections are folded in below.
- Claims that pass unchecked are tagged UNVERIFIED. See "Verification status" for what was never reached.
- **Status: Phase 1b is done and Phase 2's in-file part is decided. A PR into `master` is open for review.**
  - Resume at Phase 2's uninstalls, or Phase 3, or Phase 4. Phase 1b is kept only for its corrections.
  - The Phase 2 headline was **refuted** on 2026-07-25. Treat the remaining unexecuted claims the same way:
    run the check the doc itself names before acting on any of them.
- **A 4-lens review sweep on 2026-07-25 found 4 must-fix defects in the Phase 1b work itself**, all reproduced.
  - Three were in the awk guard, one in `sync.sh`'s new lock, and one in the "narrowed" nvidia-smi allows.
  - It also caught a wrong correction *in this doc*: the awk regression was real, just not the example given.
  - Method that caught it: differential testing against master, not reading. Reading is what produced the error.

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
  - Still in force. A PR was opened on 2026-07-25 so the review has a surface; opening it is not merging it.
  - The branch now contains master (`37a9a97`), so it is no longer behind.

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

Added 2026-07-25, during the Phase 1b session:

- **Consent: gate the irreversible only.** Reversible edits inside this worktree proceed without asking; the
  stops are file/dir deletion, plugin uninstall, any edit outside this worktree, and `git push`.
  - This relaxes the "once per phase" clause above, by user decision, for in-branch work only.
  - The permissions diff was still presented before it was applied, because the doc gated that one by name.
- **Scope of the PR: this repo only.** Phase 1b plus the parts of Phase 2 that live in tracked `settings.json`.
  - Phases 3 and 4 and the plugin uninstalls are out of it - a PR into this `master` cannot carry them.
- **`sync.sh` autosave collapsing: rejected.** Read-time filtering only. Per-session author dates are worth more
  than a shorter `git log`, and the flock is a separate, real bug fix that landed on its own merits.
- **`additionalDirectories` stays `/tmp`.** The narrowing was verified real but not worth the friction.
- **`Read(//proc/**)` and the `dmesg` gap: fix, do not just flag.** Both were found outside the original audit.

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
- ~~The branch is one commit behind master~~ - **resolved.** Master was merged in on 2026-07-25 (`dca6348`),
  and `git merge-base --is-ancestor master HEAD` now passes. It mattered exactly once; see Phase 1b step 0.
- **None of it is live.** `settings.json` registers hooks at `$HOME/.claude/hooks/`, which is still master
  byte-for-byte. No Phase 1 fix can be verified by running a session until the branch merges.

Hooks:

- awk-guard now lexes per line. The newline bypass is closed, verified end-to-end.
  - **A regression was real. The doc named the wrong example, and the first correction here was also wrong.**
    - The stated example does not regress: master lexes `cat f |\` + newline + `awk '...'` to `['cat', '\nawk']`,
      matching no awk name, so master did not deny it either. A pre-existing bypass shared by both.
    - But testing only that example and concluding "no regression" was N=1. The review sweep found the real one:
      **a multi-line quoted awk program**, which is how awk is normally written.
    - `awk '<nl>BEGIN { system("cat ~/.env") }<nl>'` was **DENY on master, ALLOW on the branch**. Per-line lexing
      unbalances the quote on each line, `shlex` raises, and the pre-existing catch turned that into "not awk".
    - Fixed by the review sweep: catch `ValueError` **inside** the token loop (shlex raises lazily, so tokens already
      yielded are kept) and union a per-line pass with a whole-command pass. Either pass alone has a hole.
    - Guarded by a 28-case differential corpus that asserts nothing master denied is now allowed.
  - The false deny was real but narrower than stated: a heredoc body line that *starts with* `awk` was denied;
    one that merely mentions awk mid-line was not. **Fixed** in `28545ce` by skipping heredoc bodies.
    - The skip only fires when the closing delimiter is really present, so a stray match cannot swallow a real
      `awk` that follows. A 10-case suite covers it, including "real awk after a heredoc" and "arith shift then awk".
  - Still open and disclaimed here: `/usr/bin/awk` (absolute path) and backtick substitution both bypass it.
    Both were confirmed open on master and on the branch - the guard is best-effort against a cooperative model.
- rumdl-md-check subtracts `old_string`, so unchanged Edit context stops re-flagging. Verified.
  - Known limit: the subtraction is text-based, not positional, so duplicating an existing >120-col line is exempt.
- Both linters resolve via PATH with a `~/.local/bin` fallback and print a one-line install pointer.
  - The **exit code did not change** (1 before, 1 after). Only exit 2 reaches the model, so a missing linter
    still fails open toward the agent: loud to the user, silent to Claude.
- **Fourth change, not previously listed**: `rumdl-md-check.py:12-15` added a `json.load` try/except that
  exits 0 on malformed stdin. That is the silent-swallow `rules/python.md:12` warns against. Drop or document it.
  - **Dropped** in `28545ce`; malformed stdin now tracebacks. Exit 0 there means "lint passed", so the swallow
    silently reported clean.
  - The doc's inconsistency, noted: `awk-guard.py` has the byte-identical pattern on **master** and was not
    flagged. It is defensible to keep - exit 0 there means "no decision", so the command still hits the normal
    prompt - but the doc never said so. Left alone as adjacent code.

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
    "Pick each subagent's model with the `delegation` skill." **Fixed** in `6d13a60` - it now points at the
    CLAUDE.md Delegation tiers, which put review on opus.
- `rules/settings-scope.md`: `paths` narrowed. The doc misquoted its own change - there is no `settings*.json`
  glob. It is two exact patterns: `**/.claude/settings.json` and `**/.claude/settings.local.json`.
- `README.md`: dropped the `InstructionsLoaded` hook pointer. **This was wrong - the hook is real.**
  - 27 references in the v2.1.219 binary, including the payload builder. **Restored** in `6d13a60`.
  - Re-confirmed at the source: `hook_event_name:v.literal("InstructionsLoaded")`, `executeInstructionsLoadedHooks`,
    `hasInstructionsLoadedHook`, and an `InstructionsLoaded:[]` slot in the hook registry object.
  - It is also the one read-only probe that would settle the `settings-scope.md` glob claim empirically.
- `.gitignore`: added `!docs/` and `!docs/*.md` in `f782c14`. Previously undocumented here.

**Phase 1b - config repo finished**, same branch, 2026-07-25. Three commits, plus the merge of master.

- **Step 0, the trap in old step 1**: master (`37a9a97`) merged into the branch *first*. Confirmed it mattered -
  the branch's `settings.json` really did carry `"model": "fable"` and `"advisorModel": "opus"`.
  - Verified after: `model` is `opus`, `advisorModel` absent. Phase 0 survived.
- **Permissions** (`077ed83`): allow 138 -> 137, deny 42 -> 27. Far short of the ~112 target - see the correction
  under Phase 1b step 1 below for why most of the claimed dead allows are not dead.
- **Sync noise** (`6d13a60`): read-time only, per the user's 2026-07-25 choice. Zero lines in `sync.sh`'s commit
  path; the README documents `git log --invert-grep --grep='^auto-save '`. Autosaves keep their per-session dates.
- **The `sync.sh` race** (`6d13a60`): one `flock` on `.git/sync.lock` around the whole run, capped at 30s.
  - Reproduced before fixing: 8 concurrent saves give 2 races on master, 0 on the branch.
- **Pending-push visibility** (`6d13a60`): new `sync.sh status`, wired to `SessionStart`.
  - Threshold is `>= 5` unpushed, not `> 0`. The doc's step 3 contradicted itself here - its *Verify* line asked
    for an indicator at 2, its body said `ahead > 0` is the steady state so an unconditional one says nothing.
    Resolved toward the threshold, picked from the live distribution: 1-3 ahead is 147 of 229 saves.
  - No upstream prints its own marker, never a count of 0. `commit_pending` now logs an explicit FAILED note,
    which covers the failed-commit symptom an ahead count cannot.
- **Hooks** (`28545ce`): awk-guard heredoc false deny fixed; `rumdl-md-check` silent swallow dropped.
- Verification: 10-case awk suite, 12-case sync suite against a throwaway `HOME`, `ruff check hooks/` clean,
  no new `rumdl` findings, `settings.json` parses. Live `~/.claude` was never written to.

## Next up

### Phase 1b - superseded, kept for its corrections

Steps 1-3 are done and recorded above. What remains here is the record of what the original text got wrong.

1. **Permissions** - done in `077ed83`. The 2026-07-25 pass checked every UNVERIFIED premise; results:
   - **The ~112 allow target was not reachable on evidence.** Landed at 137. The "~20 dead allows" were never
     enumerated because most are not dead.
   - Confirmed and applied: the curl reach (the Claude Code permissions doc recommends exactly this fix), the
     nvidia-smi prefix-anchor bypass, the hf token file (exists, mode 644), the `.env*` widening.
     - `nvidia-smi --help` says "Requires root." for the risky flags, so the 17 denies were near-dead weight
       on top of being bypassable.
   - Only `du`, `stat`, `wc` are genuinely redundant with the built-in read-only set. The docs name that set
     as `ls cat echo pwd head tail grep find wc which diff stat du cd` plus "read-only forms of `git`".
   - Exact+wildcard twins **are** redundant, now confirmed: `Bash(cmd *)` "requires the prefix to be followed
     by a space **or end-of-string**". Three dropped.
   - **`winget` / `where.exe` are not dead.** Phase 3 records Windows in regular use and this `settings.json`
     syncs there. Deleting them removes live capability. Kept - this corrects the original instruction.
   - The 13 read-only `git` allows are kept. "Read-only forms of `git`" is never enumerated in the docs, and
     `git -C` collides with the documented `cd`+`git` prompt rule. Unverifiable, and git is the hottest path.
   - `additionalDirectories` left at `/tmp` by user decision, 2026-07-25. The narrowing was real (`/tmp` is
     root-owned 1777, `/tmp/claude-1000` is wma-owned 700) but ~20 loose prior-session artifacts live in `/tmp`.
   - The 8 research WebFetch domains are **still in global** - relocation is gated, see Phase 4.
   - **Two defects the original audit missed, both fixed**: `dmesg` has the identical prefix-anchor gap (and its
     deny list never covered `-D`/`-E`/`-n`/`-S` at all); `Read(//proc/**)` exposed `/proc/<pid>/environ`.
     - The `/proc` fix had to be a **deny**, not a narrowed allow: `cat` is in the built-in read-only set and
       runs with no prompt regardless of the allow, so only a deny reaches it.
     - Cost checked first: no transcript contains a Read-tool or `cat`/`head`/`tail`/`sed` read of `/proc`.
     - On that evidence `Read(//proc/**)` was then **dropped too**, by user decision. allow 137 -> 136.
       The five denies stay and still earn their place - they are what blocks `cat /proc/<pid>/environ`, which
       the allow never governed in the first place.
2. **Sync noise** - done in `6d13a60`, read-time only. Live count re-checked: 150 of 239 on master (62%).
   - The collapsing options (amend in `save` or in `push`) were **not** built. Per-session author dates survive,
     which is what the doc named as the cost of collapsing.
   - The `flock` was built, and it went around the **whole run**, not just `commit_pending`. Locking only
     `commit_pending` leaves a `save` racing a `push`'s pull, which is one of the two shapes already in the log.
3. **Pending-push visibility** - done in `6d13a60` as a `SessionStart` note, the recommended surface.
   - Both named traps avoided: it is hard-coded to `-C "$HOME/.claude"`, and a missing upstream gets its own
     marker instead of collapsing to 0.
   - The failed-commit gap is closed by a note in `commit_pending`, the doc's own second option.
   - `statusline-command.sh` was therefore never touched, so the arrow glyph at `:101` is still open below.
4. **Merge** - both pre-merge blockers cleared: the `pr-review-sweep` reference is fixed, and the awk-guard
   "regression" turned out not to exist. A PR into `master` is open for review. **Merging is the user's call.**

### Phase 2 - plugins

**This phase's headline premise is REFUTED.** Checked 2026-07-25 by running `claude plugin list` in a WSL cwd,
the exact check the doc itself demanded. Nothing here was removed.

- ~~Remove the 8 `enabledPlugins` entries that cannot load here.~~ **All 8 report `Status: enabled`.**
  - claude-code-setup, claude-md-management, code-review, commit-commands, context7, feature-dev, pyright-lsp
    and skill-creator all load in the review worktree (`~/.claude-audit-wt`). Removing them would have dropped
    live capability -
    exactly the failure mode the doc flagged one line after making the claim.
  - The *enumeration* was right: `installed_plugins.json` really does record a `projectPath` under the Windows home
    for them. The *inference* from that to "cannot load here" is what fails - the install cache itself lives at
    `~/.claude/plugins/cache/`, a Linux path, and the user-scope `enabledPlugins` turns them on everywhere.
  - What a genuine failure looks like, for contrast: superpowers prints
    `Status: failed to load` / `enabled in project settings but isn't installed`. None of the 8 look like that.
  - Lesson for the rest of this doc: an install record's `projectPath` is not evidence about where a plugin loads.
- Uninstall superpowers (both install records, 3.9M) and remove the superpowers line from
  `ollama-modelfiles/.claude/settings.json` and `diffusion-scratch/.claude/settings.json`.
  - **Delete only the superpowers line, not the block.** `diffusion-scratch`'s block holds 7 entries; deleting it
    removes feature-dev, four life-sciences plugins and security-guidance as collateral.
  - `ollama-modelfiles`'s file *is* the block - decide whether it becomes `{}` or is deleted, before Phase 4.
  - The real win is one SessionStart hook and 14 skill descriptions, not disk.
- hookify - **disabled in `077ed83`.** Every premise re-checked at the source first; all held.
  - No `hookify.*.local.md` exists anywhere under either home directory - Linux or the Windows clone - so it
    evaluates nothing.
    Both hooks were executed directly and returned `{}`.
  - It registers four events (PreToolUse, PostToolUse, Stop, UserPromptSubmit) and occupies 5 skill-listing slots.
  - **Re-measured cost: 59ms per tool call** (PreToolUse 30ms + PostToolUse 29ms), not the 88ms recorded here.
    Provenance: 20 reps, one WSL2 host, single run - same caveat as the original figure. Ordering is what matters.
  - The rule glob is cwd-relative (`.claude/hookify.*.local.md`), so "write the rules" can only ever give
    per-project coverage, never a global guardrail.
  - Reversible: `settings.json` is tracked and the marketplace is a git URL. The two `Skill(hookify:hookify*)`
    allows were deliberately left in place so re-enabling does not need a re-grant.
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

A second pass on 2026-07-25 executed Phase 1b and closed most of the gap the first pass left.

- **Now checked at the source, corrections folded in above**: the whole Phase 1b step 1 permissions detail
  (against the live Claude Code permissions doc, not memory), the Phase 1 awk and rumdl claims (by running both
  versions), the `InstructionsLoaded` claim (in the binary), and the Phase 2 plugin-load premise (by
  `claude plugin list`). Two of these came back **refuted** - see the awk regression and the Phase 2 headline.
- **Still never reached**: all of Phase 3, and the pricing and advisor-behavior claims under "Decisions already
  made". Phase 4 keeps the first pass's coverage; nothing in it was executed.

Superseded by the above, kept so the coverage history reads straight:

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
- `statusline-command.sh:101` embeds a literal arrow glyph, against the CLAUDE.md Writing rule. Still open:
  step 3 shipped as a `SessionStart` note instead, so that file was never touched and the natural moment passed.
- The 8 research WebFetch domains are still in global `settings.json`. Deferred by the user on 2026-07-25 -
  relocation is Phase 4 work on `diffusion-scratch`, to be done with the diff shown first, outside this PR.
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
- Merge master into the branch before rewriting any whole file. Done once already (`dca6348`); master keeps
  moving, because every SessionEnd autosaves onto it.
- Pull with the app idle - a pull rewrites live config under any running session. Restart if `settings.json`
  changed.
- Deletions of runtime state (daemon files, venvs, plugin caches) are one-way. Confirm before each.
- `workflowSizeGuideline` is now `"small"` (<5 agents), set by the user on 2026-07-25. Still advisory only.
  - It is a session/config setting, not a tracked key in this repo's `settings.json`.
- No agent or workflow was spawned for Phase 1b. Every step was a single-file edit or a single check, which the
  Orchestration section already classified as inline work.
