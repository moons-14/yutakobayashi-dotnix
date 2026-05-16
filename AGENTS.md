# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# システム設定を反映（NixOS / macOS 共通）
nix run .#switch

# ビルドのみ（適用なし）
nix run .#build

# 特定のパッケージを検索
nix search nixpkgs <package>

# flake入力を更新
nix flake update
```

## Agent Skills

このリポジトリは`agent-skills-nix`でスキルを管理しています。

- **設定**: `nix/modules/home/coding-agents/agent-skills`
- **ローカルスキル**: `agents/skills/`
- **外部スキル**: `anthropics/skills`, `vercel-labs/skills`
- **デプロイ先**: `~/.agents/skills`, `~/.config/claude/skills`, `~/.config/codex/skills`

スキル名の固定リストは保守コストが高いので置かず、利用可能なローカルスキルは `agents/skills/`、有効化している外部スキルは `nix/modules/home/coding-agents/agent-skills` を正本とします。補足は `agents/README.md` を参照してください。

## Architecture

NixOS & macOS flake構成 with home-manager（nixos-unstable + nixpkgs-stable fallback）

Host 定義は root の `flake-module.nix` が `hosts` table から生成します。Host 固有の system 設定は `systems/<platform>/<hostname>/`、platform 共通の system 設定は `systems/<platform>/common.nix` や `systems/<platform>/desktop.nix`、Home Manager 設定は `homes/<platform>/<hostname>/` に置きます。アプリ単位の Home Manager 設定は direct import 用の `applications/`、option 付きの再利用可能な Home Manager 機能 module は `nix/modules/home/` に置きます。共通 module は `nix/modules/` に寄せ、NixOS profile は `nix/modules/profiles/nixos/`、Home Manager profile は `nix/modules/profiles/home/` に置きます。

独自パッケージの実体は `yutakobayashidev/nur-packages` で管理し、`dotnix` は GitHub flake input として取り込みます。ローカルの未 push 変更を試すときだけ `--override-input nur-packages path:../nur-packages` を使います。

## Key Features

### NixOS

- **WM**: Niri（スクロール可能なタイリングWM）
- **IME**: fcitx5 + hazkey（LLM変換）
- **YubiKey**: PAM U2F認証サポート（polkit, swaylock対応）
- **Development**: Docker, Tailscale, Android開発環境、UM790-ProのVirtualBox

### macOS

- **Homebrew**: GUI アプリ管理（Ghostty, Raycast, Chrome等）
- **Touch ID**: sudo認証対応
- **1Password**: Shell Plugins（gh, awscli2）

## Key Shell Shortcuts

定義場所: `zsh/config/aliases.zsh`, `zsh/functions/*.zsh`

- `rebuild` → `nix run .#switch`（NixOS / macOS 共通）
- `g` → 引数なし: ghq+fzf、引数あり: git
- `Ctrl+G` → `g` の引数なしと同じ ghq+fzf ピッカー
- `gh-q` → ghq + fzf でリポジトリ選択・clone
- `yolo` → `claude --dangerously-skip-permissions`
