{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.programs.coding-agents;
in
{
  options.my.programs.coding-agents.enable = lib.mkEnableOption "coding agent packages";

  config = lib.mkIf cfg.enable {
    home.packages =
      (with pkgs.llm-agents; [
        claude-code
        apm
        ccusage
        copilot-cli
        rtk
        vibe-kanban
        cursor-agent
        agent-browser
        entire
        spec-kit
      ])
      ++ (with pkgs; [
        continues
        waza
      ]);
  };
}
