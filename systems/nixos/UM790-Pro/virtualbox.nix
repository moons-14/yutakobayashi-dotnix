{ username, ... }:

{
  virtualisation.virtualbox.host.enable = true;
  users.users.${username}.extraGroups = [ "vboxusers" ];
}
