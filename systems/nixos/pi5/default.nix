{ inputs, username, ... }:

{
  imports = [
    inputs.nixos-hardware.nixosModules.raspberry-pi-5
    ./hardware-configuration.nix
    ../../../nix/modules/profiles/nixos/cli-server.nix
    (
      { pkgs, ... }:
      {
        programs.zsh.enable = true;

        users.users.${username} = {
          isNormalUser = true;
          description = username;
          shell = pkgs.zsh;
          extraGroups = [ "wheel" ];
        };

        nix.settings.allowed-users = [ username ];
        nix.settings.trusted-users = [
          "root"
          username
        ];
      }
    )
  ];
}
