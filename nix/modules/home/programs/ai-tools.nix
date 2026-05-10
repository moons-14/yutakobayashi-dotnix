{ pkgs, ... }:
{
  home.packages =
    (with pkgs.llm-agents; [
      claude-code
      apm
      ccusage
      copilot-cli
      opencode
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
