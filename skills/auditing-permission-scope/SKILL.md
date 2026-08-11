---
name: auditing-permission-scope
description: Audit and tighten an AI coding agent's permission/config scope (settings.json, plugin enablement, .claude tracking). Use after adding allow rules, before committing a .claude/ dir, during allowlist cleanup, or when a setup feels over-permissioned.
---

# Auditing permission scope

Audit against least privilege: the narrowest rule that works, at the narrowest tier, tracking only what is
safe to commit. Tier principle: `~/.claude/rules/repo-scoping.md` - the resource's tier; ambiguous -> ask.

Eval order: **deny > ask > allow**, first match wins, specificity ignored.
- A deny cannot carry allow-exceptions - narrow the allow instead.
- A deny does override a broad allow, but Bash rules match the command *prefix*: reordered args
  (`nvidia-smi -i 0 -pl`) slip past a flag-specific deny.

## When

- New allow rules, `additionalDirectories`, MCP servers, or workflows; before committing `.claude/`.
- Allowlist cleanup: audit the result (`fewer-permission-prompts` only appends).
- A setup feels over-permissioned or sessions feel context-heavy.
- Skip: one obviously-safe read-only entry.

## Five lenses

| Lens | Ask | Flag |
|---|---|---|
| Breadth | Wildcard wider than the workflow? | arbitrary exec / secret / outward write |
| Placement | Narrowest tier that needs it? | machine path committed; project grant in global |
| Redundancy | Covered by a broader rule? | `conda activate x` under `conda activate *` |
| Exposure | Would committing leak? | denylist gitignore; tracked tokens/transcripts |
| Context cost | Loads every session needlessly? | global domain plugin/MCP; unused skill |

## Patterns

Often missed - focus here:

- Outward/irreversible writes: `Bash(gh pr *)` (allows create/merge/close), `Bash(git push *)`, deploys ->
  narrow to read verbs (`gh pr view/list/diff`).
- `additionalDirectories` = read+write working access; a home/config dir there exposes every project -
  scope it to the one path needed.

Usually caught unaided - confirm, don't dwell: catch-alls (`Bash(*)`, unpathed Write/Edit), arbitrary exec
(`python -`, `bash -c`, `eval`, `xargs`), secret-printers (`gh auth *` -> `gh auth status`), redundant rules.
Read-only diagnostics with `*` (`ps *`, `df *`, `git log *`) are fine.

Tightening a broad allow, by risk: (1) narrow the allow to safe forms (default-deny) - preferred;
(2) keep the wildcard, deny destructive forms (prefix gap above); (3) PreToolUse hook - the only
reorder-proof block; reserve for genuinely destructive or deny-bypassing commands (e.g. `awk`).

## Tier placement

Two axes: this-project vs every-project, committed vs local. Committed/local discriminator:
machine-specificity - absolute paths and host values go in gitignored `*.local.json`; generic + safe goes
committed (solo user: committed = portable). Resource-tier examples: `git -C ~/.claude status` and global
WebFetch domains belong in `~/.claude`, not a project file.

| File | Put here |
|---|---|
| `.claude/settings.json` | generic, safe, this-project |
| `.claude/settings.local.json` | machine paths, host values |
| `~/.claude/settings.json` | narrow generic global grants, mostly read-only |
| `~/.claude/settings.local.json` | machine-specific global (SSH socket, `/proc`); caveat: `rules/settings-scope.md` |

## Context cost

MCP tools are deferred - cheap. The real per-session cost: server-instructions blocks + skill listings. Levers:

- Disable the plugin at the right tier (project overrides user - move, don't remove).
- `disable-model-invocation: true` on own skills (keeps `/`-invoke; plugin skills: disable the plugin).
- Disconnect account connectors (user action, not settings).

Deny rules and hooks do NOT shrink context: deny blocks invocation, not loading; hooks add context.

## Config-dir gitignore

Whitelist, not denylist - agent-dropped files (tokens, transcripts) then default to ignored:

```gitignore
.claude/*
!.claude/settings.json
```

Verify: `git check-ignore .claude/settings.local.json`; `git add . --dry-run` stages only safe files.

## Fix

1. Narrow > remove > move; apply via `update-config`; keep `defaultMode: default` (every unlisted call still prompts).
2. Validate JSON; confirm removals gone, narrowed rules present.
3. State the trade: which auto-approvals become prompts.
4. Context bloat is a plugin/connector fix, not a deny rule.
