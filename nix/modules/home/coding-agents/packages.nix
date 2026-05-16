{ pkgs, ... }:
{
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
}
