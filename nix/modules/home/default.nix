{ ... }:

{
  imports = [
    ./dotfiles.nix
    ./agent-skills.nix
    ./vrchat.nix
    ./services/nix-index.nix
    ./programs/ai-tools.nix
    ./programs/dev-tools.nix
    ./programs/claude-code.nix
    ./programs/codex.nix
    ./programs/opencode
    ./programs/chromium.nix
    ./programs/firefox.nix
    ./programs/git.nix
    ./programs/jj.nix
    ./programs/obs-studio.nix
    ./programs/zsh.nix
  ];

  home.username = "yuta";

  home.stateVersion = "25.11";
}
