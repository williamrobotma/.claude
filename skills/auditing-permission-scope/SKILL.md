---
name: auditing-permission-scope
description: Use when reviewing, tightening, or auditing an AI coding agent's permission settings (e.g. Claude Code settings.json allow/deny/additionalDirectories) - after adding allow rules, before committing a .claude/ config dir, during allowlist cleanup, or when a setup feels over-permissioned.
---

# Auditing Permission Scope

## Overview
Agent permission setups drift broad by default: each friction point earns a
wildcard, grants pile up at the wrong tier, and the config dir tracks more than
is safe to share. Audit against **least privilege**: the narrowest rule that
works, at the narrowest tier, tracking only config safe to commit.

Rules evaluate **deny > ask > allow** (first match wins; specificity is
ignored). A broad `deny` cannot carry allow-exceptions - narrow the `allow`
itself instead of trying to carve a hole in a deny. The reverse *does* hold:
a `deny` overrides a broad `allow`, so you can keep a convenient wildcard and
deny just its destructive forms - but Bash rules match the command *prefix*, so
reordered args (`nvidia-smi -i 0 -pl`) slip past a flag-specific deny.

Blunt issues (catch-alls, arbitrary exec, secret-printers, redundancy) get
caught unaided. This skill's value is the easily-missed dimensions: outward-write
verbs, tier placement, `additionalDirectories` reach, the whitelist gitignore
remedy, the eval order above, and **context cost** - skills/MCP/connectors that
load into every session whether or not the project needs them.

## When to use
- After adding `allow` rules or `additionalDirectories`.
- Before committing or sharing a `.claude/settings.json`.
- "Reduce permission prompts" / allowlist-cleanup requests - audit the *result*,
  not just append entries (that is `fewer-permission-prompts`, which only broadens).
- A setup feels over-permissioned, or new MCP servers / workflows were added.
- Sessions feel context-heavy, or domain plugins/MCP/connectors are enabled
  globally but only some projects need them.

Skip for a single, obviously-safe, read-only entry.

## Five scope lenses
| Lens | Ask | Flag when |
|---|---|---|
| Breadth | Does the wildcard match more than the workflow needs? | arbitrary exec / secret / outward write (below) |
| Placement | Is this at the narrowest tier that needs it? | machine path in committed file; project grant in global |
| Redundancy | Already covered by a broader rule? | `conda activate x` under `conda activate *` |
| Exposure | Would committing this dir leak anything? | denylist gitignore; tracked tokens/transcripts |
| Context cost | Does this load into every session whether the project needs it? | domain plugin/MCP/connector enabled globally; unused bundled skill |

## Over-broad patterns to flag
**Often missed - focus here:**
- **Outward / irreversible writes:** `Bash(gh pr *)` (allows create/merge/close),
  `Bash(git push *)`, deploy commands. Narrow to read verbs (`gh pr view/list/diff`).
- **`additionalDirectories` reach:** a home/config/credential dir here grants
  read+write working access across *every* project, not just a one-path read.

**Usually caught unaided - confirm, don't dwell:** catch-alls (`Bash(*)`, unpathed
`Write`/`Edit`), arbitrary exec (`Bash(python -)`, `bash -c`, `eval`, `xargs`),
secret-printers (`Bash(gh auth *)` -> `gh auth status`), rules redundant under a
broader one.

Read-only diagnostics with `*` (`ps *`, `df *`, `git diff *`, `git log *`) are fine.

**Tightening a broad allow** - three options, by risk: (1) *narrow the allow* to
specific safe forms (default-deny, no prefix gap, unlisted forms just prompt) -
preferred; (2) *keep the wildcard, deny the destructive forms* (default-allow,
convenient, prefix-gap above); (3) *PreToolUse hook* - only reorder-proof block,
reserve for genuinely destructive or deny-bypassing commands (e.g. `awk`), overkill
for style.

## Tier placement
Two axes: **scope** (this-project vs every-project) and **committed vs local**. The
committed/local discriminator is *machine-specificity*: an absolute path or
host-specific value (`/projects/wma/...`, an SSH socket) goes in the gitignored
`*.local.json`; anything generic and safe goes in the committed file, which travels
with the repo / syncs across your machines (solo user: "committed" means *portable*,
not *team-shared*). Place a grant at the tier of the *resource* it acts on, not
where you happen to be - `git -C ~/.claude status` and global WebFetch domains
belong in `~/.claude`, not a project file.

| File | Scope | Put here |
|---|---|---|
| `.claude/settings.json` | committed, this project | generic, safe, non-machine-specific (e.g. read-only MCP tool allows) |
| `.claude/settings.local.json` | gitignored, this project | machine paths, host-specific values |
| `~/.claude/settings.json` | committed, every project | generic global grants; keep narrow + mostly read-only |
| `~/.claude/settings.local.json` | gitignored, every project | machine-specific global grants (SSH socket, `/proc`) |

`additionalDirectories` = read+write working access. A home/config dir there at
global tier exposes every other project's data; scope it to the one path needed.

## Context cost: what loads every session
MCP *tools* are deferred (loaded on demand) - cheap. The real per-session cost is
**server-instructions blocks** + **skill-listing lines** (each skill's
description/when_to_use). Levers that actually shrink it:
- **Disable the plugin** (`enabledPlugins`) - removes its skills + MCP. Tiered:
  project overrides user, so *move, don't remove* - keep a domain plugin (bio,
  infra) in the projects that need it, off globally.
- **`disable-model-invocation: true`** on your *own* skills - drops the listing
  from context, keeps `/`-invoke. (Can't edit plugin skills' frontmatter - disable
  the whole plugin instead.)
- **Disconnect account connectors** (claude.ai web Connectors) - not in any
  settings.json; flag as user-action.

`deny` rules and hooks do **not** shrink context: a denied skill/tool still loads
its listing/instructions - deny blocks *invocation*, not loading; hooks *add*
context. Context bloat is a plugin/connector-enablement problem, not a permission one.

## Config-dir gitignore: whitelist, not denylist
A committed `.claude/` should **whitelist** what is safe, not ignore files
one-by-one - new agent-dropped files (tokens, transcripts, caches) then default
to ignored:
```gitignore
.claude/*
!.claude/settings.json
```
Verify: `git check-ignore .claude/settings.local.json` (ignored) and
`git add . --dry-run` (only safe files staged).

## Fix workflow
1. Narrow > remove > move. Prefer replacing a wildcard with specific verbs over
   deleting it (keeps the workflow smooth).
2. Apply via `update-config`; keep `defaultMode: default` (every unlisted call
   still prompts).
3. Validate JSON after each edit; confirm removed entries gone, narrowed ones present.
4. State the trade: tightening turns some auto-approvals into prompts - name which.
5. Context bloat is a separate fix path: disable the plugin/connector (per tier),
   not a deny rule - see Context cost.
