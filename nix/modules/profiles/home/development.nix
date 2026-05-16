{ ... }:

{
  imports = [
    ../../home/coding-agents/packages.nix
    ../../home/development/packages.nix
    ../../home/coding-agents/claude-code.nix
    ../../home/coding-agents/codex.nix
    ../../home/coding-agents/opencode
    ../../../../applications/jj
  ];

  my.programs.coding-agents.enable = true;
  my.programs.development-tools.enable = true;
  my.programs.claude-code.enable = true;
  my.programs.codex.enable = true;
  my.programs.opencode.enable = true;
}
