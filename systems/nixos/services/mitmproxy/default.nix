{ pkgs, ... }:

let
  upstreamAddress = "222.94.225.121";
  upstreamPort = 80;
  listenPort = 8081;

  addonScript = ./addon.py;
in
{
  systemd.services.mitmproxy-playground = {
    description = "mitmproxy reverse proxy playground";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = ''
        ${pkgs.mitmproxy}/bin/mitmproxy \
          --mode reverse:http://${upstreamAddress}:${toString upstreamPort}/ \
          --listen-port ${toString listenPort} \
          --set block_global=false \
          --set keep_host_header=true \
          -s ${addonScript}
      '';
      Restart = "on-failure";
      DynamicUser = true;
    };
  };
}
