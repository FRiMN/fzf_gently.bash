fzf_gently__fzf_cd() {
    local prefix query selected
    if [[ "$READLINE_LINE" =~ ^[[:space:]]*(cd)[[:space:]]+(.*)$ ]]; then
        prefix=$(fzf_gently__strip "${BASH_REMATCH[1]}")
        query=$(fzf_gently__strip "${BASH_REMATCH[2]}")
    else
        return 1
    fi

    local selected=$(find . -type d -print0 2>/dev/null | \
             fzf --read0 --prompt='Dir: ' -1 --query="${query}" \
             --height=40% --border --header-first --reverse --preview='ls -aA1 {}' --preview-window=right:25 \
             --border-label="$prefix" --border-label-pos=3 --margin=1,0,0) && \
    fzf_gently___fzf_set_readline "$prefix" "'$selected'"
}
