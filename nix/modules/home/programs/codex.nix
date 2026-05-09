{
  lib,
  config,
  pkgs,
  dotfilesDir,
  ...
}:

let
  codexConfigDir = "${config.xdg.configHome}/codex";
  codexDotfilesDir = "${dotfilesDir}/codex";
  tomlFormat = pkgs.formats.toml { };
  settings = {
    approval_policy = "on-request";
    model = "gpt-5.5";
    model_reasoning_effort = "high";
    personality = "pragmatic";
    project_doc_fallback_filenames = [ "CLAUDE.md" ];
    web_search_request = true;

    mcp_servers.deepwiki = {
      url = "https://mcp.deepwiki.com/mcp";
    };

    plugins = {
      "github@openai-curated".enabled = true;
      "browser-use@openai-bundled".enabled = true;
      "documents@openai-primary-runtime".enabled = true;
      "spreadsheets@openai-primary-runtime".enabled = true;
      "presentations@openai-primary-runtime".enabled = true;
    };

    notice.model_migrations."gpt-5.2-codex" = "gpt-5.4";
  };
  codexConfig = tomlFormat.generate "codex-config" settings;
in
{
  home.packages = [ pkgs.llm-agents.codex ];

  home.sessionVariables = {
    CODEX_HOME = codexConfigDir;
  };

  home.activation.writeCodexConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    mkdir -p "${codexConfigDir}"
    ${pkgs.coreutils}/bin/install -m 644 ${codexConfig} "${codexConfigDir}/config.toml"
  '';

  xdg.configFile."codex/AGENTS.md".source =
    config.lib.file.mkOutOfStoreSymlink "${codexDotfilesDir}/AGENTS.md";
}
