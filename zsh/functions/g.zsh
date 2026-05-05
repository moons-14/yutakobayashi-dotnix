#!/usr/bin/env zsh

# g: 引数なし→ghq+fzfでcd、引数あり→gitに転送
function __ghq_pick() {
  local selected_dir
  selected_dir="$(ghq list --full-path | fzf --height 40% --reverse)"

  [[ -n "$selected_dir" ]] && printf '%s\n' "$selected_dir"
}

function g() {
  if [[ $# -eq 0 ]]; then
    local selected_dir
    selected_dir="$(__ghq_pick)" || return
    [[ -n "$selected_dir" ]] && cd -- "$selected_dir"
  else
    git "$@"
  fi
}

function __ghq_pick_widget() {
  local selected_dir
  selected_dir="$(__ghq_pick)" || return

  if [[ -n "$selected_dir" ]]; then
    cd -- "$selected_dir" || return
    zle reset-prompt
  fi
}
zle -N __ghq_pick_widget
bindkey '^G' __ghq_pick_widget
