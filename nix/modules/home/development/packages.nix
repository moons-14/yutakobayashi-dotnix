# 外部flake input由来の開発ツール
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.my.programs.development-tools;
in
{
  options.my.programs.development-tools.enable = lib.mkEnableOption "development tools";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      gogcli
      repiq
    ];
  };
}
