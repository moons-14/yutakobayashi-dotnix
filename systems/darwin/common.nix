{
  inputs,
  lib,
  username,
  ...
}:

{
  imports = [
    ../common.nix
    ../../nix/modules/darwin
    inputs.comin.darwinModules.comin
    inputs.sops-nix.darwinModules.sops
  ];

  services.comin = {
    enable = true;
    remotes = [
      {
        name = "origin";
        url = "https://github.com/yutakobayashidev/dotnix";
      }
    ];
  };

  services.prometheus.exporters.node.enable = true;
  users.users._prometheus-node-exporter.home = lib.mkForce "/private/var/lib/prometheus-node-exporter";

  users.users.${username}.home = "/Users/${username}";

  nix.settings.trusted-users = [
    "root"
    username
  ];

  system.primaryUser = username;
  system.stateVersion = 6;
  system.startup.chime = false;

  my.services.caffeinate = {
    enable = true;
    preventSleepOnCharge = true;
  };

  my.services.newsyslog.enable = true;

  nix.gc.interval = {
    Weekday = 0;
    Hour = 2;
    Minute = 0;
  };

  nix.settings.always-allow-substitutes = true;
}
