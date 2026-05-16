{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.my.programs.opencode;
  opencodeConfigDir = "${config.xdg.configHome}/opencode";

  # Read settings from external JSON file
  settingsJsonText = builtins.readFile ./settings.json;
in
{
  options.my.programs.opencode.enable = lib.mkEnableOption "OpenCode";

  config = lib.mkIf cfg.enable {
    # OpenCode package
    home.packages = lib.mkAfter [ pkgs.llm-agents.opencode ];

    # Generate opencode.json from settings file
    xdg.configFile."opencode/opencode.json" = {
      text = settingsJsonText;
    };
  };
}
