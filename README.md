# ~/.claude config

Version-controlled subset of `~/.claude` (Claude Code global config), synced across
machines via a private GitHub repo.

Reference: the official `~/.claude` directory docs (what each file/dir is, load order,
settings schema) - https://code.claude.com/docs/en/claude-directory

## What this is

`~/.claude` holds both durable config and a large amount of per-machine, fast-churning
state (sessions, history, caches, a running daemon). This repo tracks ONLY the durable,
machine-independent config and ignores everything else.

## Tracking model: deny-all allowlist

`.gitignore` ignores everything (`*`) and re-includes specific files - see `.gitignore` itself for the current allowlist (do not duplicate it here; a copy drifts).

`skills/` and `rules/` admit only `*.md`: the gate stays deny-by-default even inside
them, so a non-md file an agent drops there (a token, a cache) is ignored, not
auto-tracked. This is deliberate. These directories can accumulate secrets and
volatile state, so the safe default is "track nothing unless explicitly allowed."
Never invert this to a denylist: one forgotten entry leaks a credential - this
also means individual rule/skill files are never named in `.gitignore`; the
extension gate sweeps them in or out uniformly.

Tracked:

- `CLAUDE.md` - global preferences / instructions
- `settings.json` - Claude Code harness settings (permissions, plugins, model, hooks)
- `.gitignore` - the allowlist itself
- `.gitattributes` - normalizes line endings to LF (`rules/git-line-endings.md`), routes settings.json through the `merge-settings.py` driver
- `sync.sh` - the save/pull/push sync script (only `save` runs from a hook)
- `merge-settings.py` - settings.json merge driver (see "Handling mismatches")
- `statusline-command.sh` - custom status line (settings.json points at it; needs `python3`)
- `provision.sh` - optional per-machine provisioning, called from sync.sh if present + executable (idempotent symlinks etc.)
- `rumdl.toml` - user-global rumdl config; provision.sh symlinks ~/.config/rumdl/rumdl.toml at it
- `ruff.toml` - user-global ruff config (fallback when a project has none); provision.sh symlinks ~/.config/ruff/ruff.toml at it
- `environment-devtools.yml` - optional fallback dev-CLI conda env (WIP; see its header comment)
- `hooks/*.py` - hook scripts registered in settings.json (e.g. the awk PreToolUse guard)
- `commands/sync-push.md` - the `/sync-push` slash command; delegates the gated push to the `sync-pusher` agent
- `agents/*.md` - subagents (e.g. `sync-pusher`: runs the push on haiku, off the main context)
- `skills/**/*.md` - personal skills (markdown only; gate stays deny-by-default)
- `rules/**/*.md` - `.claude/rules/` instructions, global scope, optionally
  path-gated per file (markdown only; gate stays deny-by-default)
- `README.md`, `LICENSE`

Deliberately NOT tracked (and why):

- `.credentials.json` - live auth tokens; never commit
- `CLAUDE.local.md` - machine-local instructions; see "Machine-local instructions" below
- `history.jsonl`, `sessions/`, `projects/`, `file-history/`, `shell-snapshots/`,
  `session-env/` - per-machine session state; append-only, conflict-prone
- `daemon.*`, `*.lock`, `*-status.json` - live process state; harmful to share
- `cache/`, `paste-cache/`, `backups/`, `*-cache.json` - regenerable caches
- `plugins/` - per-machine install state (abs paths, version SHAs, catalog cache);
  your enabled set lives in `settings.json` `enabledPlugins`

## Machine-local instructions

For a Claude Code instruction that must never sync to another machine - not even as
an inert reference in a tracked file - two mechanisms auto-load with a zero tracked
footprint. Both are discovered from disk by directory scan, so git tracking governs
only whether they sync, never whether they load (reading a file never consults git):

- `~/.claude/rules/<name>.md` with no `paths:` frontmatter - the genuinely global one.
  It loads at launch in every session, in every project, at the same priority as
  `~/.claude/CLAUDE.md` (docs: "personal rules in `~/.claude/rules/` apply to every
  project"; rules "without `paths` are loaded at launch"). The `!rules/**/*.md` allowlist
  tracks rules by default; to keep one local, add an ignore-back line such as
  `rules/*.local.md` after it. A `paths:`-scoped rule instead loads lazily - only when
  Claude reads a file matching the glob - so it never fires on a no-file conversational
  turn; omit `paths:` for anything that must always apply.
- `~/.claude/CLAUDE.local.md` - zero-footprint but not global. `~/.claude/CLAUDE.md` is
  special-cased to load in every session regardless of cwd; `CLAUDE.local.md` is not,
  loading only via directory-walk-up-from-cwd, so `~/.claude/CLAUDE.local.md` only takes
  effect when cwd is inside `~/.claude`. It needs no `.gitignore` line (root `*` covers
  it) and no reference. Use it for instructions you only need in `~/.claude` sessions;
  use an untracked `rules/*.md` for ones you need everywhere.

`hooks/` and `settings.json` cannot auto-load untracked: a hook fires only once
registered in `settings.json`, and that registration is itself tracked. So `rules/`
and `CLAUDE.local.md` are the only zero-footprint local mechanisms - and only an
untracked no-`paths` `rules/*.md` is both zero-footprint and global. Check what
actually loaded with `/memory`, or the `InstructionsLoaded` hook (logs what loads,
when, and why). Ref: https://code.claude.com/docs/en/memory

## Adding a new tracked file

Because of the allowlist, a new file is ignored until you allow it. Add a matching
`!path` line to `.gitignore`. For a file in a subdirectory you must allow the
directory too:

    !subdir/
    !subdir/file

## Syncing across machines

Git is snapshot sync, not real-time sync. Two habits keep it painless:

1. Pull at the start of a config session, push right after editing.
2. Pulls MERGE, so a divergent machine reconciles instead of refusing or overwriting.

Typical session:

    bash ~/.claude/sync.sh pull       # or /sync-push, which pulls then pushes
    # ... edit config, or let Claude Code change settings.json ...
    /sync-push                        # merge in the remote, then push

## Handling mismatches / conflicts

`settings.json` is rewritten per machine (notably `/model` and `/effort` "save as
default"), so two machines editing it between syncs used to conflict. Fix:
`.gitattributes` routes it through `merge-settings.py`, a merge driver registered
by `sync.sh`. When the only keys that differ are per-machine prefs (model,
effortLevel, ...) it keeps this machine's copy. Otherwise it falls back to git's
normal merge, but first rewrites the per-machine lines in the incoming copy to
match ours - so those prefs never spuriously conflict just because a real key
(a permission, a plugin) changed alongside them, while that real change still
surfaces as a visible conflict rather than being silently dropped. Model/effort
thus stay per-machine and `/model`/`/effort` keep working everywhere.
See `rules/settings-scope.md`.

A merge pull reconciles a divergent remote on its own; it only stops if the same
lines clash, leaving conflict markers in the small file(s):

    bash ~/.claude/sync.sh pull   # merges; stops with markers only on a real clash
    # resolve the markers in CLAUDE.md / settings.json
    git add <file> && git commit  # completes the merge
    /sync-push

Pull when the app is idle: the working tree is your live config, so a pull rewrites it
under any running session. Restart the session if `settings.json` changed.

## Automation

`sync.sh` plus one Claude Code hook (defined in `settings.json`, so it travels with
the repo and self-distributes):

- `SessionEnd` -> `sync.sh save` : commits local changes locally. No network, no
  auth - works on every machine; logs how many commits await push.

Everything that touches the network is interactive and deliberate:

- `/sync-push` (or `bash ~/.claude/sync.sh push`) : commit any pending local change
  (so a mid-session `/model`/`/effort` edit can't block the pull), merge in the remote, then push.
- `bash ~/.claude/sync.sh pull` : merge in the remote (run at the start of a session).

Why no hook does the network: a hook runs a non-interactive shell with no SSH agent,
so it cannot authenticate a passphrase-protected key (nor be confirmed - hooks bypass
the permission system). Network sync therefore runs only in an interactive session,
where your ssh-agent holds the unlocked key. Transport is SSH only
(`git@github.com:...`); git authenticates via the ssh-agent, never a token.

pull/push MERGE rather than fast-forward-only: a divergent remote is reconciled, not
refused, and nothing on either side is silently overwritten or deleted. Bare `git push`
is not in the permission allowlist, so `/sync-push` prompts - that prompt is the gate.
`sync.sh` always exits 0 (never stalls a session) and logs to `sync.log` (untracked).

## GitHub access model (git = SSH, API = gh CLI, no token in env)

How git and the GitHub API are reached - two channels, neither puts a token in the
environment. The `settings.json` half below is tracked here, so it is identical on every
machine; the shell half (`~/.bashrc`, not tracked) is per-machine - reproduce it the same
way on each.

- **git transport = SSH.** clone/fetch/push use `git@github.com:...` and authenticate
  through the ssh-agent - the same agent the config-repo sync above relies on. Recommended
  per-machine setup: one shared agent at `~/.ssh/agent.sock`, exported in `~/.bashrc`
  *above* the interactive guard so login and non-interactive tool shells alike inherit it.
  No token involved.
- **API / automation = `gh` CLI via Bash.** `gh` reads its own credential store
  (`~/.config/gh/hosts.yml`) and needs nothing in the environment; Claude runs `gh pr`,
  `gh issue`, `gh api`, etc. as ordinary Bash commands.

Deliberately NOT used: a global `GITHUB_PERSONAL_ACCESS_TOKEN` export. An env token sits
in every process's environment - inherited by every subshell and tool - for a single
consumer, the remote GitHub MCP plugin (`github@claude-plugins-official`, kept disabled).
git needs no token and `gh` carries its own, so nothing exports one. If you ever enable
that plugin, inject the token at launch instead of globally:

    claude() { GITHUB_PERSONAL_ACCESS_TOKEN="$(gh auth token 2>/dev/null)" command claude "$@"; }

so it lives only in claude's process tree and is minted fresh from gh (follows rotation).

What `settings.json` allows without a prompt, prompts for, or denies outright:

- **allow** (no prompt): read-only `gh` subcommands - `gh pr view/list/diff/checks/status`,
  `gh issue view/list/status`, `gh repo view`, `gh run/workflow/release ...`, `gh search`,
  and `gh auth status` (which masks the token).
- **prompt** (not allowlisted, so each use asks): writes (`gh pr create`, `gh pr merge`,
  `gh issue close`, ...) and `gh api` with a mutating `--method` (prefix-matching can't tell
  a GET from a POST). Add specific write commands to the allowlist to run them unattended.
- **deny** (hard-blocked): `gh auth token` and direct reads of `~/.config/gh/hosts.yml` -
  Claude never needs the raw token (git uses SSH, gh reads its store itself).

The token in `~/.config/gh/hosts.yml` is gh's own credential (`gho_...`, mode 600); rotate
it with `gh auth logout -h github.com && gh auth login`. Same posture as the config-repo
sync above: SSH-only transport, token never in the env.

## New-machine bootstrap

Fresh machine with no `~/.claude` yet - just clone (nothing local to lose):

    git clone git@github.com:williamrobotma/.claude.git ~/.claude

Existing `~/.claude` with content you want to MERGE in. Do it as a real merge so a
file that exists only on the remote can never be deleted, and install the allowlist
(the gate) BEFORE staging anything so secrets/state stay ignored:

    cd ~/.claude
    git init -b master
    git remote add origin git@github.com:williamrobotma/.claude.git
    git fetch origin

    git checkout origin/master -- .gitignore     # 1. install the gate FIRST
    git add -A                                    # 2. gate active => only allowlisted files staged
    git commit -m "local ~/.claude on $(hostname) before merge"

    git merge --no-commit --allow-unrelated-histories origin/master   # 3. union; pause to review
    # resolve any conflicts: union settings.json permissions.allow and keep its hooks
    # block; for infra files just take the remote (git checkout origin/master -- sync.sh)
    git add -A && git commit                      # finalize (works clean or post-conflict)
    git branch --set-upstream-to=origin/master master

    chmod +x sync.sh statusline-command.sh
    git check-ignore .credentials.json           # prints the name => safely ignored
    git push                                      # once your agent holds the key

Why a merge and not `git reset origin/master`: a reset makes HEAD the remote but
leaves only this machine's files in the tree, so every remote-only file (`sync.sh`,
`skills/`, ...) looks DELETED - and `add -A && commit && push` would wipe it for every
machine. A merge takes the union and conflicts only on real overlaps; a plain
`git push` is rejected by git unless it fast-forwards, so it cannot nuke the remote.

To instead discard local entirely and take the canonical config (deliberate; this
DOES destroy local changes):

    git reset --hard origin/master
