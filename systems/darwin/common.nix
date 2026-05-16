{ username, ... }:

{
  imports = [
    ../common.nix
    ../../nix/modules/darwin
  ];

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
