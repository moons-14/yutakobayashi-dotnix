{
  inputs,
  lib,
  ...
}:

{
  imports = [
    ../common.nix
    inputs.nixos-hardware.nixosModules.raspberry-pi-5
    ../../../nix/modules/profiles/nixos/cli-server.nix
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
