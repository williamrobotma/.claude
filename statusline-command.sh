#!/bin/bash
# Status line matching ~/.bashrc color prompt:
#   bold green \u@\h : bold blue \w
input=$(cat)

user_host="$(whoami)@$(hostname -s)"

IFS=$'\x1f' read -r cwd model effort used_tokens ctx_max used_pct five_h five_h_reset seven_d <<< "$(printf '%s' "$input" | python3 -c '
import json, sys, datetime
d = json.load(sys.stdin)
def g(*keys):                       # nested lookup; missing/None -> "" (matches jq join of nulls)
    x = d
    for k in keys:
        if not isinstance(x, dict): return ""
        x = x.get(k)
    return "" if x is None else str(x)

# resets_at is unix epoch seconds. Render as an absolute local clock time, not a
# countdown: a fixed clock is correct whenever the line is drawn, so it needs no
# refresh to stay accurate (a countdown would drift between renders).
resets_at = g("rate_limits", "five_hour", "resets_at")   # "" if missing/None
five_h_reset_disp = datetime.datetime.fromtimestamp(int(resets_at)).strftime("%H:%M") if resets_at else ""

print("\x1f".join([
    g("workspace", "current_dir"),
    g("model", "display_name"),
    g("effort", "level"),
    g("context_window", "total_input_tokens"),
    g("context_window", "context_window_size"),
    g("context_window", "used_percentage"),
    g("rate_limits", "five_hour", "used_percentage"),
    five_h_reset_disp,
    g("rate_limits", "seven_day", "used_percentage"),
]))
')"

# Use CLAUDE_CODE_MAX_CONTEXT_TOKENS (custom limit) if set and smaller than
# Claude Code's reported max_tokens; otherwise fall back to max_tokens.
override_active=0
if [ -n "${CLAUDE_CODE_MAX_CONTEXT_TOKENS:-}" ] && [ "${CLAUDE_CODE_MAX_CONTEXT_TOKENS:-0}" -lt "${ctx_max:-0}" ] 2>/dev/null; then
  ctx_max="${CLAUDE_CODE_MAX_CONTEXT_TOKENS}"
  override_active=1
fi

# Prefer Claude Code's reported used_percentage; compute from tokens when it is
# absent or when a custom (override) limit is in effect. Keeps ctx_pct non-empty
# whenever tokens are known, so pct_color always has a number to band on.
ctx_pct="$used_pct"
if [ "$override_active" = 1 ] || [ -z "$ctx_pct" ]; then
  [ -n "$used_tokens" ] && [ -n "$ctx_max" ] && [ "$ctx_max" != "0" ] && \
    ctx_pct=$(awk "BEGIN { printf \"%.1f\", ($used_tokens / $ctx_max) * 100 }")
fi

# Compact token counts: k is the floor unit (every value carries a suffix, so
# 0 -> 0k, never a bare number), promoting to M at 999500 (where %.0f would
# otherwise round to "1000k"). When both share a suffix only the denominator
# carries it (142/200k not 142k/200k).
fmt_token_pair() {
  awk -v a="$1" -v b="$2" 'BEGIN {
    if (b >= 999500) { bs = "M"; bd = b / 1000000 } else { bs = "k"; bd = b / 1000 }
    if (a >= 999500) { as = "M"; ad = a / 1000000 } else { as = "k"; ad = a / 1000 }
    if (as == bs) printf "%.0f/%.0f%s", ad, bd, bs
    else printf "%.0f%s/%.0f%s", ad, as, bd, bs
  }'
}
ctx_disp=""
[ -n "$used_tokens" ] && [ -n "$ctx_max" ] && [ "$ctx_max" != "0" ] && \
  ctx_disp="$(fmt_token_pair "$used_tokens" "$ctx_max")"

dir_name="${cwd##*/}"
branch="$(git -C "$cwd" branch --show-current 2>/dev/null)"

ESC=$'\033'
RESET="${ESC}[00m"
BOLD_GREEN="${ESC}[01;32m"
BOLD_BLUE="${ESC}[01;34m"
CYAN="${ESC}[36m"
DIM="${ESC}[2m"
GREEN="${ESC}[32m"
YELLOW="${ESC}[33m"
RED="${ESC}[31m"
MUTED="${ESC}[38;5;243m"

pct_color() {
    local p="${1%.*}"
    if [ "$p" -ge 90 ]; then printf '%s' "$RED"
    elif [ "$p" -ge 70 ]; then printf '%s' "$YELLOW"
    else printf '%s' "$GREEN"
    fi
}

line="${BOLD_GREEN}${user_host}${RESET}:${BOLD_BLUE}${dir_name}${RESET}"
[ -n "$branch" ] && line="${line} ${DIM}(${RESET}${CYAN}${branch}${RESET}${DIM})${RESET}"

# Group A: [model (effort)](context) - tight adjacency, no gap.
group_a="${DIM}[${RESET}${model}"
[ -n "$effort" ] && group_a="${group_a} ${MUTED}(${effort})${RESET}"
group_a="${group_a}${DIM}]${RESET}"
[ -n "$ctx_disp" ] && group_a="${group_a}${DIM}(${RESET}$(pct_color "$ctx_pct")${ctx_disp}${RESET}${DIM})${RESET}"
line="${line} ${group_a}"

# Group B: 5h:pct%->reset - tight adjacency, no gap.
if [ -n "$five_h" ]; then
  group_b="${DIM}5h:${RESET}$(pct_color "$five_h")${five_h%.*}%${RESET}"
  [ -n "$five_h_reset" ] && group_b="${group_b}${DIM}→${five_h_reset}${RESET}"
  line="${line} ${group_b}"
fi

# 7d rate-limit usage: surfaced only once it enters the warning band (>=70%),
# where the number starts to matter; hidden otherwise to keep the line short.
if [ -n "$seven_d" ] && [ "${seven_d%.*}" -ge 70 ] 2>/dev/null; then
  line="${line} ${DIM}7d:${RESET}$(pct_color "$seven_d")${seven_d%.*}%${RESET}"
fi

# CLAUDE_CODE_ATTRIBUTION_HEADER=0 breaks the auto-mode classifier (429 -> "temporarily unavailable")
# See: https://github.com/anthropics/claude-code/issues/64585
# The daemon inherits this from whichever session first started it,
# so background sessions silently carry a stale env forever -
# this is the workaround (surface it in the status line).
if [ -n "${CLAUDE_CODE_ATTRIBUTION_HEADER:-}" ]; then
  line="${line} ${YELLOW}[ATTR:0]${RESET}"
fi

printf '%s' "$line" 2>/dev/null || \
echo "${user_host}: ${cwd}" 2>/dev/null
