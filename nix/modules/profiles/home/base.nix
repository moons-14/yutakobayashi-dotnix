{ ... }:

{
  imports = [
    ../../home/dotfiles
    ../../home/coding-agents/agent-skills.nix
    ../../home/services/nix-index.nix
    ../../home/shell/zsh.nix
  ];

  my.programs.agent-skills.enable = true;
}
