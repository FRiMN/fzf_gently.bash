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
