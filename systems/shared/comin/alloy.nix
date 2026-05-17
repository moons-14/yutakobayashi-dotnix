{
  config,
  inputs,
  pkgs,
  ...
}:

let
  hostname = config.networking.hostName;
  lokiPort =
    inputs.self.outputs.nixosConfigurations.B450M-Pro4.config.services.loki.configuration.server.http_listen_port;
  endpoint = "http://B450M-Pro4.tail29d068.ts.net:${toString lokiPort}/loki/api/v1/push";

  writeBlock = ''
    loki.write "default" {
      endpoint {
        url = "${endpoint}"
      }
    }
  '';

  alloyConfig =
    if pkgs.stdenv.hostPlatform.isDarwin then
      ''
        local.file_match "comin" {
          path_targets = [{
            __path__ = "${config.launchd.daemons.comin.serviceConfig.StandardOutPath}",
            job      = "comin",
            host     = "${hostname}",
            os       = "darwin",
          }]
        }

        loki.process "comin" {
          forward_to = [loki.write.default.receiver]

          stage.logfmt {
            mapping = {
              "level" = "",
              "msg"   = "",
            }
          }
          stage.labels {
            values = {
              level = "",
            }
          }
        }

        loki.source.file "comin" {
          targets       = local.file_match.comin.targets
          forward_to    = [loki.process.comin.receiver]
          tail_from_end = true
        }

        ${writeBlock}
      ''
    else
      ''
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

        ${writeBlock}
      '';
in
{
  my.services.alloy = {
    enable = true;
    configs.comin = alloyConfig;
  };
}
