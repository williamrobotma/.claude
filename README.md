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

## New-machine bootstrap

Fresh machine with no `~/.claude` yet:

    git clone git@github.com:williamrobotma/.claude.git ~/.claude

Machine where Claude Code already created `~/.claude`:

    cd ~/.claude
    # back up local copies first if you want them:
    cp CLAUDE.md CLAUDE.md.bak 2>/dev/null; cp settings.json settings.json.bak 2>/dev/null
    git init
    git remote add origin git@github.com:williamrobotma/.claude.git
    git fetch origin
    git reset --hard origin/master   # overwrites tracked files with synced versions

Untracked local state (sessions, caches, credentials) is preserved by the reset:
the allowlist ignores it, so `reset --hard` only touches tracked files.
