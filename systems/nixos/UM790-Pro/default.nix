{
  inputs,
  username,
  ...
}:

{
  imports = [
    inputs.sops-nix.nixosModules.sops
    (
      { username, ... }:
      {
        sops.age.keyFile = "/home/${username}/.config/sops/age/keys.txt";
      }
    )
    ../../../nix/modules/linux
    ../../../nix/modules/linux/hermes-agent
    ./hardware-configuration.nix
    ../../../nix/modules/profiles/nixos/gui.nix
    inputs.nix-hazkey.nixosModules.hazkey
    (
      { username, ... }:
      {
        virtualisation.virtualbox.host.enable = true;
        users.users.${username}.extraGroups = [ "vboxusers" ];
      }
    )
  ];
}
