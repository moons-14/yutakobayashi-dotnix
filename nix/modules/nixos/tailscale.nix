{ config, lib, ... }:
let
  cfg = config.my.services.tailscale;
in
{
  options.my.services.tailscale = {
    enable = lib.mkEnableOption "Tailscale VPN";

    acceptDns = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };

    acceptRoutes = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    services.tailscale = {
      enable = true;
      extraUpFlags =
        lib.optional (!cfg.acceptDns) "--accept-dns=false"
        ++ lib.optional cfg.acceptRoutes "--accept-routes";
    };
  };
}
