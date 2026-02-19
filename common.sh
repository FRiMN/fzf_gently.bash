#!/usr/bin/env bash
#
# Common utility functions for fzf_gently.bash
# Provides core functions used by all modules
#

# any_f FUNC1 [FUNC2 ...]
# Executes the provided functions in order and returns 0 (success)
# if at least one of them returns 0. Subsequent functions after the first
# successful one are not called (short-circuit evaluation).
# Returns 1 if no function completed successfully.
fzf_gently__any_f() {
    local func
    for func in "$@"; do
        if "$func"; then
            return 0
        fi
    done
    return 1
}

# strip STRING
# Removes leading and trailing whitespace from the input string.
# Returns the trimmed string via stdout.
fzf_gently___strip() {
    local var="$*"
    # Remove leading and trailing whitespace using parameter expansion
    var="${var#"${var%%[![:space:]]*}"}"   # Remove leading whitespace
    var="${var%"${var##*[![:space:]]}"}"   # Remove trailing whitespace
    printf '%s' "$var"
}

fzf_set_readline__pattern="^('|\")?[[:space:]]*('|\")?$"
# fzf_set_readline PREFIX SELECTED
# Sets the READLINE_LINE with the prefix and selected value.
# Only updates if the selected value is non-empty and not just quotes/spaces.
fzf_gently___fzf_set_readline() {
    if [[ $# -lt 2 ]]; then
        echo "Error: at least 2 arguments required" >&2
        return 1
    fi

    local selected="$2"
    local prefix="$1"
    if [[ -n "$selected" ]] && [[ ! "$selected" =~ $fzf_set_readline__pattern ]]; then
        READLINE_LINE="$prefix $selected"
        READLINE_POINT=${#READLINE_LINE}
    fi
}

# Checks READLINE_LINE against a (cmd, subcmd) pattern
# Usage: fzf_gently___cmd_matches cmd subcmds prefix_var query_var
# Returns 0 and writes to the provided prefix/query variables if matched
fzf_gently___cmd_matches() {
    local cmd="$1"
    local subcmds="$2"
    local -n __prefix=$3
    local -n __query=$4

    local pattern
    if [[ -n "$subcmds" ]]; then
        # Convert space-separated subcmds to regex alternation (OR)
        # e.g., "checkout branch" -> "checkout|branch" for pattern matching
        local alts=${subcmds// /|}
        pattern="^([[:space:]]*${cmd}[[:space:]]+(${alts}))[[:space:]]*(.*)$"
    else
        pattern="^([[:space:]]*${cmd})[[:space:]]+(.*)$"
    fi

    if [[ "$READLINE_LINE" =~ $pattern ]]; then
        __prefix=$(fzf_gently___strip "${BASH_REMATCH[1]}")
        if [[ -n "$subcmds" ]]; then
            __query=$(fzf_gently___strip "${BASH_REMATCH[3]}")
        else
            __query=$(fzf_gently___strip "${BASH_REMATCH[2]}")
        fi
        return 0
    fi
    return 1
}
