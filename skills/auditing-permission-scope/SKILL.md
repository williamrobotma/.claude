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
itself instead of trying to carve a hole in a deny.

Blunt issues (catch-alls, arbitrary exec, secret-printers, redundancy) get
caught unaided. This skill's value is the easily-missed dimensions: outward-write
verbs, tier placement, `additionalDirectories` reach, the whitelist gitignore
remedy, and the eval order above.

## When to use
- After adding `allow` rules or `additionalDirectories`.
- Before committing or sharing a `.claude/settings.json`.
- "Reduce permission prompts" / allowlist-cleanup requests - audit the *result*,
  not just append entries (that is `fewer-permission-prompts`, which only broadens).
- A setup feels over-permissioned, or new MCP servers / workflows were added.

Skip for a single, obviously-safe, read-only entry.

## Four scope lenses
| Lens | Ask | Flag when |
|---|---|---|
| Breadth | Does the wildcard match more than the workflow needs? | arbitrary exec / secret / outward write (below) |
| Placement | Is this at the narrowest tier that needs it? | machine path in committed file; project grant in global |
| Redundancy | Already covered by a broader rule? | `conda activate x` under `conda activate *` |
| Exposure | Would committing this dir leak anything? | denylist gitignore; tracked tokens/transcripts |

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

## Tier placement
| File | Scope | Put here |
|---|---|---|
| `.claude/settings.json` | committed, shared | generic, safe, project-wide grants only |
| `.claude/settings.local.json` | gitignored, personal | machine paths, personal grants |
| `~/.claude/settings.json` | every project | keep narrow + mostly read-only; a grant here applies everywhere |

`additionalDirectories` = read+write working access. A home/config dir there at
global tier exposes every other project's data; scope it to the one path needed.

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
