{ config, ... }:

let
  hostname = config.networking.hostName;
in
{
  my.services.alloy.configs.hermes-agent = ''
    loki.source.journal "hermes_agent" {
      forward_to = [loki.write.default.receiver]
      matches    = "_SYSTEMD_UNIT=microvm@hermes-agent.service"
      labels     = {
        job  = "hermes-agent",
        host = "${hostname}",
        os   = "linux",
      }
    }
  '';
}
