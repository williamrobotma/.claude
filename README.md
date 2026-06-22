# ~/.claude config

Version-controlled subset of `~/.claude` (Claude Code global config), synced across
machines via a private GitHub repo.

## What this is

`~/.claude` holds both durable config and a large amount of per-machine, fast-churning
state (sessions, history, caches, a running daemon). This repo tracks ONLY the durable,
machine-independent config and ignores everything else.

## Tracking model: deny-all allowlist

`.gitignore` ignores everything (`*`) and re-includes specific files:

    *
    !CLAUDE.md
    !settings.json
    !.gitignore
    !README.md
    !LICENSE

This is deliberate. The directory contains secrets and volatile state, so the safe
default is "track nothing unless explicitly allowed." Never invert this to a denylist:
one forgotten entry leaks a credential.

Tracked:

- `CLAUDE.md`     - global preferences / instructions
- `settings.json` - Claude Code harness settings (permissions, plugins, model)
- `.gitignore`    - the allowlist itself
- `README.md`, `LICENSE`

Deliberately NOT tracked (and why):

- `.credentials.json` - live auth tokens; never commit
- `settings.local.json` - per-machine setting overrides
- `history.jsonl`, `sessions/`, `projects/`, `file-history/`, `shell-snapshots/`,
  `session-env/` - per-machine session state; append-only, conflict-prone
- `daemon.*`, `*.lock`, `*-status.json` - live process state; harmful to share
- `cache/`, `paste-cache/`, `backups/`, `*-cache.json` - regenerable caches

## Adding a new tracked file

Because of the allowlist, a new file is ignored until you allow it. Add a matching
`!path` line to `.gitignore`. For a file in a subdirectory you must allow the
directory too:

    !subdir/
    !subdir/file

## Syncing across machines

Git is snapshot sync, not real-time sync. Two habits keep it painless:

1. Pull before you edit, push right after.
2. Use fast-forward-only pulls so a machine never silently merges.

Typical session:

    git pull --ff-only
    # ... edit config, or let Claude Code change settings.json ...
    git add -A && git commit -m "..." && git push

## Handling mismatches / conflicts

`settings.json` is the main conflict risk because Claude Code rewrites it on each
machine. To minimize churn, push machine-specific keys into `settings.local.json`
(untracked) and keep `settings.json` to the shared baseline.

When a push is rejected (histories diverged):

    git pull --ff-only      # refuses on divergence -> then:
    git pull --rebase       # replay local commits on top of remote
    # resolve conflict markers in the small file(s)
    git add <file> && git rebase --continue
    git push

Pull when the app is idle: the working tree is your live config, so a pull rewrites it
under any running session. Restart the session if `settings.json` changed.

## Automation

`sync.sh` plus two Claude Code hooks (defined in `settings.json`, so they travel
with the repo and self-distribute) keep machines current, while the push stays a
deliberate, confirmed step:

- `SessionStart` -> `sync.sh pull` : fast-forward only; automatic, never merges.
- `SessionEnd`   -> `sync.sh save` : commits local changes locally; never pushes.
- Push is manual: `/sync-push` (or `bash ~/.claude/sync.sh push`). Bare `git push`
  is not in the permission allowlist, so it prompts - that prompt is the gate.

Hooks run non-interactive shell and bypass the permission system, which is why push
is kept out of them: a hooked push could not be confirmed. `sync.sh` always exits 0
(never stalls a session) and logs to `sync.log` (untracked).

## New-machine bootstrap

Fresh machine with no `~/.claude` yet:

    git clone git@github.com:williamrobotma/.claude.git ~/.claude

Existing `~/.claude` with content, not yet a git repo, whose local config you want
to MERGE in. Attach the repo without touching your files, then turn on the allowlist
so state and secrets are ignored before you stage anything:

    cd ~/.claude
    git init -b master
    git remote add origin git@github.com:williamrobotma/.claude.git
    git fetch origin
    git reset --mixed origin/master                  # adopt history; keep local files
    git branch --set-upstream-to=origin/master master
    git checkout origin/master -- .gitignore README.md LICENSE sync.sh commands
    chmod +x sync.sh
    git check-ignore .credentials.json               # prints the name => safely ignored

Now only `CLAUDE.md` and `settings.json` show as modified (your local versions).
Reconcile each, then commit and push:

    # take the synced version:    git checkout origin/master -- CLAUDE.md
    # or merge by hand: edit CLAUDE.md / settings.json to combine both sides
    git add -A && git commit -m "merge $(hostname) local config"
    git push

`settings.json` is JSON: union the `permissions.allow` list and keep any local keys,
rather than picking one side wholesale. Make sure the merged file keeps the `hooks`
block - that is what activates the auto pull/commit on this machine.

To instead discard local and take the canonical config wholesale:

    git reset --hard origin/master
