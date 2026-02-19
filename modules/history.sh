fzf_gently__fzf_history() {
    local prefix selected
    prefix=${READLINE_LINE}
    selected=$(fc -rl 1 | sed 's/^\s*[0-9]*\s*//' | awk '!seen[$0]++' | \
        fzf --height 40% --reverse --border --prompt="⏳History:" --scheme=history --query "${prefix}") && \
    fzf_gently___fzf_set_readline "$prefix" "$selected"
}
