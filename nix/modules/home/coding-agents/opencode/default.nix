{
  pkgs,
  lib,
  config,
  ...
}:
let
  opencodeConfigDir = "${config.xdg.configHome}/opencode";

  # Read settings from external JSON file
  settingsJsonText = builtins.readFile ./settings.json;
in
{
  # OpenCode package
  home.packages = lib.mkAfter [ pkgs.llm-agents.opencode ];

  # Generate opencode.json from settings file
  xdg.configFile."opencode/opencode.json" = {
    text = settingsJsonText;
  };

}
