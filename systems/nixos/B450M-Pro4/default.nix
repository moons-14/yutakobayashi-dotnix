{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ../common.nix
    ../services/nextcloud
    ../services/immich
    ../services/gitea
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "B450M-Pro4";
  networking.networkmanager.enable = true;
  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  hardware.px4_drv.enable = true;

  hardware.nvidia = {
    open = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      config.boot.kernelPackages.nvidiaPackages.stable
    ];
  };

  boot.kernelModules = [ "nvidia-uvm" ];

  hardware.nvidia-container-toolkit.enable = true;

  virtualisation.docker.enable = true;
  virtualisation.docker.daemon.settings.features.cdi = true;

  system.stateVersion = "25.11";
}
