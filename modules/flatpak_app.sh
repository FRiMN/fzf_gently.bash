fzf_gently__fzf_flatpak_app() {
    local prefix query selected
    if [[ "$READLINE_LINE" =~ ^([[:space:]]*flatpak[[:space:]]+(run))[[:space:]]*(.*)$ ]]; then
        prefix=$(fzf_gently__strip "${BASH_REMATCH[1]}")
        query=$(fzf_gently__strip "${BASH_REMATCH[3]}")
    else
        return 1
    fi

    local selected=$(flatpak list --app --columns=name,application | \
        tail -n +1 | \
        awk 'NF {
            id = $NF
            sub(/[[:space:]]+[^[:space:]]+$/, "", $0)
            gsub(/^[[:space:]]+|[[:space:]]+$/, "", $0)
            if (length($0)) printf "%s \033[90m(%s)\033[0m\x1e%s\n", $0, id, id
        }' | \
        fzf --prompt='App: ' -1 --query="$query" \
            --delimiter=$'\x1e' --with-nth=1 --nth=1 \
            --height=40% --border --reverse --ansi \
            --border-label="$prefix" --border-label-pos=3 --margin=1,0,0 | \
        cut -d $'\x1e' -f2) && \
    fzf_gently___fzf_set_readline "$prefix" "$selected"
}
