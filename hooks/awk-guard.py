#!/usr/bin/env python3
"""PreToolUse(Bash) guard: deny awk, redirect to Read / cut|grep|sort.

awk is a full language (system(), getline) so it can't be pre-approved, and
unlike the Read tool and recognized read-commands it bypasses the settings
deny rules (.env, keys). Its safe uses (field/row extraction) are all covered
by auto-approved tools, so deny + redirect loses nothing. Anything that is not
an awk *command* falls through untouched to the normal permission flow.
"""
import json
import re
import shlex
import sys

# tokens that separate pipeline/list stages -> the next word is a fresh command
OPERATORS = {"|", "||", "&&", ";", "|&", "&", "(", ")", "{", "}", "\n"}
# wrappers + shell keywords that precede the real command of a stage
SKIP_BEFORE_CMD = {"sudo", "env", "nohup", "nice", "command", "time", "stdbuf",
                   "do", "then", "else", "elif"}


def stage_commands(command):
    """Leading command word of each stage, quote-aware (so `grep awk` is safe)."""
    lexer = shlex.shlex(command, posix=True, punctuation_chars=True)
    lexer.whitespace_split = True
    cmds, expect_cmd = [], True
    for tok in lexer:
        if tok in OPERATORS:
            expect_cmd = True
        elif not expect_cmd:
            continue
        elif re.fullmatch(r"[A-Za-z_]\w*=.*", tok) or tok in SKIP_BEFORE_CMD:
            continue  # env assignment / wrapper -> real command is the next word
        else:
            cmds.append(tok)
            expect_cmd = False
    return cmds


try:
    data = json.load(sys.stdin)
except (json.JSONDecodeError, ValueError):
    sys.exit(0)  # unreadable input -> fall through to normal permission flow

command = (data.get("tool_input") or {}).get("command", "")
try:
    uses_awk = any(c in ("awk", "gawk", "mawk") for c in stage_commands(command))
except ValueError:
    uses_awk = False  # unbalanced quotes etc. -> fall through to normal prompt

if uses_awk:
    reason = ("awk is not pre-approved (it can exec via system()/getline and "
              "bypasses the Read deny rules). Read a file with the Read tool; "
              "extract fields/rows from piped output with cut/grep/sort/sed "
              "(all auto-approved).")
    print(json.dumps({"hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "permissionDecision": "deny",
        "permissionDecisionReason": reason,
    }}))
sys.exit(0)
