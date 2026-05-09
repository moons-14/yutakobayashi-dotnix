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

- **設定**: `nix/modules/home/agent-skills.nix`
- **ローカルスキル**: `agents/skills/`
- **外部スキル**: `anthropics/skills`, `vercel-labs/skills`
- **デプロイ先**: `~/.agents/skills`, `~/.config/claude/skills`, `~/.config/codex/skills`

スキル名の固定リストは保守コストが高いので置かず、利用可能なローカルスキルは `agents/skills/`、有効化している外部スキルは `nix/modules/home/agent-skills.nix` を正本とします。補足は `agents/README.md` を参照してください。

## Architecture

NixOS & macOS flake構成 with home-manager（nixos-unstable + nixpkgs-stable fallback）

```
flake.nix                          # エントリポイント
├── agents/
│   └── skills/                    # Claude Codeスキル
├── raycast/                       # macOS Raycastスクリプト
├── nix/
│   ├── hosts/                     # ホスト固有の設定
│   │   ├── UM790-Pro/             # NixOS (x86_64-linux)
│   │   │   ├── default.nix        # モジュール構成
│   │   │   └── hardware-configuration.nix  # boot, network, hardware, logind
│   │   ├── X870-Stell-Legend-WiFi/ # NixOS-WSL (x86_64-linux)
│   │   │   ├── default.nix        # モジュール構成
│   │   │   └── hardware-configuration.nix  # WSL設定, hostname
│   │   ├── pi5/                   # NixOS (aarch64-linux, headless Raspberry Pi 5)
│   │   │   ├── default.nix        # モジュール構成
│   │   │   └── hardware-configuration.nix  # boot, network, filesystem
│   │   └── M2-MacBook-Air/        # macOS (aarch64-darwin)
│   │       └── default.nix        # ホスト名設定
│   ├── profiles/                  # プロファイル定義
│   │   ├── cli-minimal.nix        # 最小CLI環境
│   │   ├── cli.nix                # CLI環境（docker, tailscale含む）
│   │   ├── pi5.nix                # headless Pi 5環境
│   │   ├── gui.nix                # GUI環境（niri, audio, bluetooth含む）
│   │   └── darwin.nix             # macOS環境
│   ├── modules/
│   │   ├── linux/                 # NixOS/Linuxシステムモジュール
│   │   │   ├── default.nix
│   │   │   ├── packages.nix       # システムパッケージ（zsh, nix-ld）
│   │   │   ├── nix.nix            # Nix設定
│   │   │   ├── user.nix           # ユーザー設定 + home-manager統合
│   │   │   ├── home-packages.nix  # Linux固有ユーザーパッケージ
│   │   │   ├── niri.nix           # Niri WM + greetd
│   │   │   ├── input.nix          # fcitx5 + hazkey
│   │   │   ├── audio.nix          # pipewire
│   │   │   ├── bluetooth.nix
│   │   │   ├── pam.nix            # PAM/polkit設定（YubiKey, U2F認証）
│   │   │   ├── docker.nix
│   │   │   ├── tailscale.nix
│   │   │   ├── android.nix
│   │   │   ├── fonts.nix
│   │   │   ├── ssh.nix
│   │   │   ├── printing.nix       # CUPS printing
│   │   │   ├── locale.nix          # i18n/タイムゾーン共通設定
│   │   │   ├── ipfs.nix            # Kubo/IPFS daemon
│   │   │   └── programs/          # Linux固有home-managerプログラム
│   │   │       ├── firefox.nix    # Firefox profile/search設定
│   │   │       ├── niri.nix       # Niri home設定
│   │   │       ├── waybar.nix
│   │   │       ├── swayidle.nix
│   │   │       └── swaylock.nix
│   │   ├── darwin/                # macOS nix-darwinモジュール
│   │   │   ├── default.nix
│   │   │   ├── system.nix         # macOS defaults (Dock, Finder, trackpad等)
│   │   │   ├── homebrew.nix       # Homebrew cask管理
│   │   │   ├── fonts.nix          # macOSフォント設定
│   │   │   ├── nix.nix            # Nix設定
│   │   │   └── packages.nix       # macOS固有ユーザーパッケージ（brew-nix含む）
│   │   ├── home/                  # home-manager共通設定
│   │   │   ├── default.nix        # 共通設定（zsh, git, claude-code等）
│   │   │   ├── packages.nix       # 共通ユーザーパッケージ
│   │   │   └── programs/          # 共通プログラム設定
│   │   │       ├── common-cli.nix # 共通CLIプログラム集約
│   │   │       ├── zsh.nix
│   │   │       ├── ghostty/
│   │   │       ├── neovim.nix
│   │   │       ├── tmux/
│   │   │       ├── git.nix
│   │   │       ├── gh.nix
│   │   │       ├── jj.nix
│   │   │       ├── claude-code.nix
│   │   │       ├── bat.nix
│   │   │       ├── btop.nix
│   │   │       └── fastfetch/
│   │   └── lib/                   # ヘルパー関数
│   │       └── helpers/
│   └── overlays/                  # dotnixローカルのoverlay / override
│       ├── default.nix            # ローカルoverlayの集約
│       ├── dev-tools.nix
│       ├── speechrecognition.nix
│       ├── tree-sitter-moonbit.nix
│       └── ...
└── nvim/                          # Neovim設定（Lua）
    └── lua/plugins/               # lazy.nvim プラグイン設定
```

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
