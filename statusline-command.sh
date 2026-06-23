#!/bin/bash
# Status line matching ~/.bashrc color prompt:
#   bold green \u@\h : bold blue \w
input=$(cat)

user_host="$(whoami)@$(hostname -s)"

IFS=$'\x1f' read -r cwd model effort used_tokens ctx_max five_h seven_d <<< "$(printf '%s' "$input" | jq -r '[
  .workspace.current_dir,
  .model.display_name,
  .effort.level,
  .context_window.total_input_tokens,
  .context_window.context_window_size,
  .rate_limits.five_hour.used_percentage,
  .rate_limits.seven_day.used_percentage
] | join([31] | implode)')"

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

printf '%s' "$line" 2>/dev/null || \
echo "${user_host}: ${cwd}" 2>/dev/null || \
echo "bmm"
