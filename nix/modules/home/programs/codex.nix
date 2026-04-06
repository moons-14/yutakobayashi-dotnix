{
  config,
  pkgs,
  dotfilesDir,
  ...
}:

let
  codexDotfilesDir = "${dotfilesDir}/codex";
in
{
  home.packages = [ pkgs.llm-agents.codex ];

  home.sessionVariables = {
    CODEX_HOME = "${config.xdg.configHome}/codex";
  };

  xdg.configFile."codex/config.toml".source =
    config.lib.file.mkOutOfStoreSymlink "${codexDotfilesDir}/config.toml";

  xdg.configFile."codex/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${codexDotfilesDir}/AGENTS.md";
}
