# Agent Skills

このディレクトリはClaude Codeで使用するスキルを管理します。

## スキル管理

スキルは`agent-skills-nix`フレームワークで管理されています。

- **設定**: `nix/modules/home/agent-skills.nix`
- **ローカルスキル**: `agents/skills/`
- **デプロイ先**:
  - `~/.agents/skills`
  - `~/.config/claude/skills`
  - `~/.config/codex/skills`

## スキルの追加

1. `agents/skills/<skill-name>/`ディレクトリを作成
2. `SKILL.md`ファイルを作成
3. `nh os switch`で反映

## スキル一覧の見方

- ローカルスキルは `agents/skills/` 配下を見ればよい
- 有効化している外部スキルソースと明示スキルは `nix/modules/home/agent-skills.nix` が正本
- 外部カタログ:
  - Anthropic: https://github.com/anthropics/skills
  - Vercel: https://github.com/vercel-labs/skills
  - Obsidian: https://github.com/kepano/obsidian-skills
