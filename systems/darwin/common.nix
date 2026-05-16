{ username, ... }:

{
  imports = [
    ../../nix/modules/darwin
    ../../nix/modules/shared/nix
  ];

  users.users.${username}.home = "/Users/${username}";

  nix.settings.trusted-users = [
    "root"
    username
  ];

  system.primaryUser = username;
  system.stateVersion = 6;
  system.startup.chime = false;

  nix.gc.interval = {
    Weekday = 0;
    Hour = 2;
    Minute = 0;
  };

  nix.settings.always-allow-substitutes = true;
}
