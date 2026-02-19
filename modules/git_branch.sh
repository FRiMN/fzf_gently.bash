#!/usr/bin/env bash
#
# git_branch module - Git branch selection
# Activates on: git checkout <C-f> or git branch <C-f>
# Uses fzf to select branches with commit preview
#

fzf_gently__show_branch_info() {
    local branch="${1:-HEAD}"
    local commit_date
    commit_date=$(git log --format="%ar" -1 "$branch" 2>/dev/null) || return
    printf "\033[32mLast commit:\033[0m %s\n" "$commit_date"
    git log -n 10 --pretty=format:"[%an] %s" $branch
}
export -f fzf_gently__show_branch_info

fzf_gently__fzf_git_branch() {
    local prefix query selected
    if [[ "$READLINE_LINE" =~ ^([[:space:]]*git[[:space:]]+(checkout|branch))[[:space:]]*(.*)$ ]]; then
        prefix=$(fzf_gently__strip "${BASH_REMATCH[1]}")
        query=$(fzf_gently__strip "${BASH_REMATCH[3]}")
    else
        return 1
    fi

    selected=$(git branch -a --format='%(refname:short)' | \
             fzf --ansi --prompt='Branch: ' -1 --query="${query}" \
             --preview='fzf_gently__show_branch_info {}' --height=40% --border --header-first --reverse \
             --border-label="$prefix" --border-label-pos=3 --margin=1,0,0) && \
    fzf_gently___fzf_set_readline "$prefix" "$selected"
}
