{
  inputs,
  lib,
  username,
  ...
}:

{
  imports = [
    inputs.nixos-hardware.nixosModules.raspberry-pi-5
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

  boot.loader.generic-extlinux-compatible.enable = true;

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
    options = [
      "fmask=0077"
      "dmask=0077"
    ];
  };

  networking.hostName = "pi5";
  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  system.stateVersion = "25.11";
}
