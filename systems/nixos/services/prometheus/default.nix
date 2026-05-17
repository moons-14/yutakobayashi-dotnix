{
  config,
  inputs,
  lib,
  ...
}:

let
  builders = [
    "UM790-Pro"
  ];
  servers = [
    "B450M-Pro4"
    "pi5"
  ];
  nixosMachines = inputs.self.outputs.nixosConfigurations;
  targetsFor =
    hosts:
    lib.mapAttrsToList (
      name: value:
      let
        inherit (value.config.services.prometheus.exporters.node) port;
        host = if name == config.networking.hostName then "127.0.0.1" else name;
      in
      "${host}:${toString port}"
    ) (lib.filterAttrs (name: _: lib.elem name hosts) nixosMachines);
in

{
  services.prometheus = {
    enable = true;
    listenAddress = "127.0.0.1";
    scrapeConfigs = [
      {
        job_name = "node";
        static_configs = [
          {
            labels.role = "builders";
            targets = targetsFor builders;
          }
          {
            labels.role = "servers";
            targets = targetsFor servers;
          }
        ];
      }
    ];
  };
}
