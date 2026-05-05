#!/usr/bin/env zsh

# W: git worktreeをfzf検索して移動
function W() {
  local selected

  selected=$(
    git wt \
      | awk 'NR>1 { path=$1; if ($1 == "*") path=$2; name=path; gsub(/.*\//, "", name); printf "%s\t%s\n", name, path }' \
      | fzf --tmux --reverse \
          --with-nth=1 --delimiter=$'\t' \
          --preview 'git -C {2} log --oneline --graph -20' \
      | cut -f2
  )

  if [[ -n "$selected" ]]; then
    cd "$selected"
  fi
}
