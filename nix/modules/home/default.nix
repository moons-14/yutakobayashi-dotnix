{ ... }:

{
  imports = [
    ./dotfiles.nix
    ./agent-skills.nix
    ./vrchat.nix
    ./programs/ai-tools.nix
    ./programs/dev-tools.nix
    ./programs/claude-code.nix
    ./programs/codex.nix
    ./programs/chromium.nix
    ./programs/firefox.nix
    ./programs/git.nix
    ./programs/jj.nix
    ./programs/obs-studio.nix
    ./programs/zsh.nix
  ];

  # nix-index for command-not-found and comma
  programs.nix-index.enable = true;
  programs.nix-index-database.comma.enable = true;

  home.username = "yuta";

  home.stateVersion = "25.11";
}
