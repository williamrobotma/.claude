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
# (newlines separate stages too, but shlex eats them as whitespace - see below)
OPERATORS = {"|", "||", "&&", ";", "|&", "&", "(", ")", "{", "}"}
# wrappers + shell keywords that precede the real command of a stage
SKIP_BEFORE_CMD = {"sudo", "env", "nohup", "nice", "command", "time", "stdbuf",
                   "do", "then", "else", "elif"}
# `<<EOF`, `<<-EOF`, `<< 'EOF'`. The lookarounds keep the `<<<` herestring out;
# a word-shaped delimiter keeps the shift in `$((x << 2))` out.
HEREDOC = re.compile(r"(?<!<)<<(-?)(?!<)\s*(['\"]?)([A-Za-z_]\w*)\2")


def _closes(line, dash, delim):
    """Whether `line` is the heredoc terminator.

    bash wants the delimiter alone at column 0; only `<<-` lets it be
    indented, and only with tabs.
    """
    line = line.rstrip("\r")
    return (line.lstrip("\t") if dash else line) == delim


def command_lines(command):
    """Lines of `command` minus heredoc bodies - a body is data, not code.

    Skips only when the closing delimiter line is really there, so a stray
    match cannot swallow the rest of the command (and with it a real awk).
    """
    lines = command.split("\n")  # bash ends a line on \n and nothing else
    kept, i = [], 0
    while i < len(lines):
        line = lines[i]
        kept.append(line)
        i += 1
        for dash, _, delim in HEREDOC.findall(line):
            end = i
            while end < len(lines) and not _closes(lines[end], dash, delim):
                end += 1
            if end < len(lines):
                i = end + 1
    return kept


def stage_commands(command):
    r"""Leading command word of each stage, quote-aware (`grep awk` is safe).

    Lexes twice and unions the result, because either pass alone has a hole.
    Per line, because shlex never emits "\n" as a token, so one pass over the
    whole string lets a command after a newline ride the previous stage
    unseen. Whole string, because a quote spanning newlines unbalances the
    individual lines - and one bad line must not blind the guard to the rest.
    Arg-position wrappers (find -exec, xargs, bash -c) stay out of scope by
    design - the guard is best-effort against a cooperative model.
    """
    cmds = []
    for chunk in [*command_lines(command), command]:
        lexer = shlex.shlex(chunk, posix=True, punctuation_chars=True)
        lexer.whitespace_split = True
        expect_cmd = True
        try:
            for tok in lexer:
                if tok in OPERATORS:
                    expect_cmd = True
                elif not expect_cmd:
                    continue
                elif re.fullmatch(r"[A-Za-z_]\w*=.*", tok) or tok in SKIP_BEFORE_CMD:
                    continue  # env assignment / wrapper -> real command is next
                else:
                    cmds.append(tok)
                    expect_cmd = False
        except ValueError:
            # shlex raises lazily on an unbalanced quote. Keep what this chunk
            # already yielded; the other pass covers what it could not reach.
            continue
    return cmds


try:
    data = json.load(sys.stdin)
except (json.JSONDecodeError, ValueError):
    sys.exit(0)  # unreadable input -> fall through to normal permission flow

command = (data.get("tool_input") or {}).get("command", "")
if any(c in ("awk", "gawk", "mawk") for c in stage_commands(command)):
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
