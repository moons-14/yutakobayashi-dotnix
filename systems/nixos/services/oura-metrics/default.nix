{ config, pkgs, ... }:

let
  ouraExporter = pkgs.writeScript "oura_exporter.py" (builtins.readFile ./oura_exporter.py);
  textfileDir = "/var/lib/node-exporter-textfile";
  nodeExporterUser = config.services.prometheus.exporters.node.user;
  nodeExporterGroup = config.services.prometheus.exporters.node.group;
in
{
  sops.secrets.oura-personal-access-token = {
    sopsFile = ./secrets.yaml;
  };

  sops.templates."oura-exporter.env" = {
    content = ''
      OURA_PERSONAL_ACCESS_TOKEN=${config.sops.placeholder.oura-personal-access-token}
    '';
    owner = nodeExporterUser;
    group = nodeExporterGroup;
  };

  systemd.services.oura-exporter = {
    description = "Oura Ring Prometheus textfile exporter";
    path = [ pkgs.python3 ];
    serviceConfig = {
      Type = "oneshot";
      User = nodeExporterUser;
      Group = nodeExporterGroup;
      ExecStart = ''
        ${pkgs.python3}/bin/python3 ${ouraExporter} \
          --output ${textfileDir}/oura.prom \
          --date today \
          --tz Asia/Tokyo
      '';
      EnvironmentFile = config.sops.templates."oura-exporter.env".path;
    };
  };

  systemd.timers.oura-exporter = {
    description = "Run Oura Ring exporter every 30 minutes";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*:0/30";
      Persistent = true;
    };
  };
}
