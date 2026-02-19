#!/usr/bin/env bash
#
# Common utility functions for fzf_gently.bash
# Provides core functions used by all modules
#

# any_f FUNC1 [FUNC2 ...]
# Выполняет переданные функции по порядку и возвращает 0 (успех),
# если хотя бы одна из них вернула 0. Остальные функции после первой
# успешной не вызываются (short-circuit evaluation).
# Возвращает 1, если ни одна функция не завершилась успешно.
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
fzf_gently__strip() {
    local var="$*"
    # Remove leading and trailing whitespace using parameter expansion
    var="${var#"${var%%[![:space:]]*}"}"   # Remove leading whitespace
    var="${var%"${var##*[![:space:]]}"}"   # Remove trailing whitespace
    printf '%s' "$var"
}

fzf_set_readline__pattern="^('|\")?[[:space:]]*('|\")?$"
fzf_gently___fzf_set_readline() {
    if [[ $# -lt 2 ]]; then
        echo "Ошибка: нужно минимум 2 аргумента" >&2
        return 1
    fi

    local selected="$2"
    local prefix="$1"
    if [[ -n "$selected" ]] && [[ ! "$selected" =~ $fzf_set_readline__pattern ]]; then
        READLINE_LINE="$prefix $selected"
        READLINE_POINT=${#READLINE_LINE}
    fi
}

# Проверяет READLINE_LINE на соответствие (cmd, subcmd)
# Использование: fzf_gently___cmd_matches cmd subcmds prefix_var query_var
# Возвращает 0 и записывает в переданные переменные prefix/query если совпало
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
        __prefix=$(fzf_gently__strip "${BASH_REMATCH[1]}")
        if [[ -n "$subcmds" ]]; then
            __query=$(fzf_gently__strip "${BASH_REMATCH[3]}")
        else
            __query=$(fzf_gently__strip "${BASH_REMATCH[2]}")
        fi
        return 0
    fi
    return 1
}
