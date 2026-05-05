#!/usr/bin/env zsh

# gip: グローバルIPアドレスを表示
function gip() {
  curl -s http://ipecho.net/plain
  echo
}
