#!/bin/bash
# Status line matching ~/.bashrc color prompt:
#   bold green \u@\h : bold blue \w
input=$(cat)

user_host="$(whoami)@$(hostname -s)"

IFS=$'\x1f' read -r cwd model effort used_tokens ctx_max five_h seven_d <<< "$(printf '%s' "$input" | python3 -c '
import json, sys
d = json.load(sys.stdin)
def g(*keys):                       # nested lookup; missing/None -> "" (matches jq join of nulls)
    x = d
    for k in keys:
        if not isinstance(x, dict): return ""
        x = x.get(k)
    return "" if x is None else str(x)
print("\x1f".join([
    g("workspace", "current_dir"),
    g("model", "display_name"),
    g("effort", "level"),
    g("context_window", "total_input_tokens"),
    g("context_window", "context_window_size"),
    g("rate_limits", "five_hour", "used_percentage"),
    g("rate_limits", "seven_day", "used_percentage"),
]))
')"

# Use CLAUDE_CODE_MAX_CONTEXT_TOKENS (custom limit) if set and smaller than
# Claude Code's reported max_tokens; otherwise fall back to max_tokens.
if [ -n "${CLAUDE_CODE_MAX_CONTEXT_TOKENS:-}" ] && [ "${CLAUDE_CODE_MAX_CONTEXT_TOKENS:-0}" -lt "${ctx_max:-0}" ] 2>/dev/null; then
  ctx_max="${CLAUDE_CODE_MAX_CONTEXT_TOKENS}"
fi

ctx_pct=""
[ -n "$used_tokens" ] && [ -n "$ctx_max" ] && [ "$ctx_max" != "0" ] && \
  ctx_pct=$(awk "BEGIN { printf \"%.1f\", ($used_tokens / $ctx_max) * 100 }")

dir_name="${cwd##*/}"
branch="$(git -C "$cwd" branch --show-current 2>/dev/null)"

model_disp="$model"
[ -n "$effort" ] && model_disp="${model_disp} (${effort})"

ESC=$'\033'
RESET="${ESC}[00m"
BOLD_GREEN="${ESC}[01;32m"
BOLD_BLUE="${ESC}[01;34m"
CYAN="${ESC}[36m"
DIM="${ESC}[2m"
GREEN="${ESC}[32m"
YELLOW="${ESC}[33m"
RED="${ESC}[31m"

pct_color() {
    local p="${1%.*}"
    if [ "$p" -ge 90 ]; then printf '%s' "$RED"
    elif [ "$p" -ge 70 ]; then printf '%s' "$YELLOW"
    else printf '%s' "$GREEN"
    fi
}

line="${BOLD_GREEN}${user_host}${RESET}:${BOLD_BLUE}${dir_name}${RESET}"
[ -n "$branch" ] && line="${line} ${DIM}(${RESET}${CYAN}${branch}${RESET}${DIM})${RESET}"
line="${line} ${DIM}[${model_disp}]${RESET}"
[ -n "$ctx_pct" ] && line="${line}${DIM} ctx:${RESET}$(pct_color "$ctx_pct")${ESC}[01m${ctx_pct%.*}%${RESET}"
[ -n "$five_h" ] && line="${line}${DIM} 5h:${RESET}$(pct_color "$five_h")${five_h%.*}%${RESET}"
[ -n "$seven_d" ] && line="${line}${DIM} 7d:${RESET}$(pct_color "$seven_d")${seven_d%.*}%${RESET}"

# CLAUDE_CODE_ATTRIBUTION_HEADER=0 breaks the auto-mode classifier (429 → "temporarily unavailable")
# See: https://github.com/anthropics/claude-code/issues/64585
# The daemon inherits this from whichever session first started it,
# so background sessions silently carry a stale env forever —
# this is the workaround (surface it in the status line).
if [ -n "${CLAUDE_CODE_ATTRIBUTION_HEADER:-}" ]; then
  line="${line} ${YELLOW}[ATTR:0]${RESET}"
fi

printf '%s' "$line" 2>/dev/null || \
echo "${user_host}: ${cwd}" 2>/dev/null || \
echo "bmm"
