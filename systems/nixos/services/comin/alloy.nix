{ config, inputs, ... }:

let
  hostname = config.networking.hostName;
  lokiPort =
    inputs.self.outputs.nixosConfigurations.B450M-Pro4.config.services.loki.configuration.server.http_listen_port;
in
{
  my.services.alloy = {
    enable = true;
    configs.comin = ''
      loki.write "default" {
        endpoint {
          url = "http://B450M-Pro4:${toString lokiPort}/loki/api/v1/push"
        }
      }

      loki.relabel "comin" {
        forward_to = [loki.write.default.receiver]

        rule {
          source_labels = ["__journal__systemd_unit"]
          target_label  = "unit"
        }
        rule {
          source_labels = ["__journal_priority_keyword"]
          target_label  = "level"
        }
      }

      loki.source.journal "comin" {
        forward_to = [loki.relabel.comin.receiver]
        matches    = "_SYSTEMD_UNIT=comin.service"
        labels     = {
          job  = "comin",
          host = "${hostname}",
          os   = "linux",
        }
      }
    '';
  };
}
