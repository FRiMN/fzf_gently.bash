#!/usr/bin/env bash
#
# cd module - Interactive directory navigation
# Activates on: cd <C-f>
# Uses fzf to select directories with preview
#

fzf_gently__fzf_cd() {
    local prefix query selected
    fzf_gently___cmd_matches "cd" "" prefix query || return 1

    selected=$(find . -type d -print0 2>/dev/null | \
             fzf --read0 --prompt='Dir: ' -1 --query="${query}" \
             --height=40% --border --header-first --reverse --preview='ls -aA1 {}' --preview-window=right:25 \
             --border-label="$prefix" --border-label-pos=3 --margin=1,0,0) && \
    fzf_gently___fzf_set_readline "$prefix" "'$selected'"
}
