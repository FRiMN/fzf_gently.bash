#!/usr/bin/env bash
#
# ollama_model module - Ollama model selection
# Uses fzf to select installed Ollama models
#

fzf_gently__fzf_ollama_model() {
    local prefix query selected
    fzf_gently___cmd_matches "ollama" "run show cp rm" prefix query || return 1

    selected=$(ollama list | awk 'NR>1{print $1}' | \
        fzf --prompt='Model: ' -1 --query="$query" --preview='ollama show {}' \
            --height=60% --border --reverse \
            --border-label="$prefix" --border-label-pos=3 --margin=1,0,0) && \
    fzf_gently___fzf_set_readline "$prefix" "$selected"
}


fzf_gently__fzf_ollama_running_model() {
    local prefix query selected
    fzf_gently___cmd_matches "ollama" "stop" prefix query || return 1

    selected=$(ollama ps | awk 'NR>1{print $1}' | \
        fzf --prompt='Running model: ' -1 --query="$query" \
            --height=4 --border --reverse \
            --border-label="$prefix" --border-label-pos=3 --margin=1,0,0) && \
    fzf_gently___fzf_set_readline "$prefix" "$selected"
}
