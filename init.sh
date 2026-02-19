#!/usr/bin/env bash

#SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_DIR="${BASH_SOURCE[0]%/*}"

_load_files() {
    local dir="$1"
    if [[ -d "$dir" ]]; then
        for file in "$dir"/*.sh; do
            [[ -f "$file" ]] && source "$file"
        done
    fi
}

source "${SCRIPT_DIR}/common.sh"
_load_files "${SCRIPT_DIR}/modules"

# Exclude fzf_gently__fzf_history.
# Include only modules for commands (prefixes).
fzf_gently__all_commands() {
    fzf_gently__any_f \
    fzf_gently__fzf_git_branch \
    fzf_gently__fzf_flatpak_app \
    fzf_gently__fzf_cd
}