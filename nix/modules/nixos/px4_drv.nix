{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  cfg = config.hardware.px4_drv;
in
{
  options.hardware.px4_drv = {
    enable = lib.mkEnableOption "px4_drv ISDB-T/S tuner driver for PLEX PX-W3U4 etc.";
  };

  config = lib.mkIf cfg.enable {
    boot.extraModulePackages = [
      (config.boot.kernelPackages.callPackage ./px4_drv-package.nix {
        src = inputs.px4_drv;
      })
    ];

    boot.kernelModules = [ "px4_drv" ];

    hardware.firmware = [
      (pkgs.runCommand "px4_drv-firmware" { } ''
        mkdir -p $out/lib/firmware
        cp ${inputs.px4_drv}/etc/it930x-firmware.bin $out/lib/firmware/it930x-firmware.bin
      '')
    ];

    services.udev.packages = [
      (pkgs.runCommand "px4_drv-udev-rules" { } ''
        mkdir -p $out/etc/udev/rules.d
        cp ${inputs.px4_drv}/etc/99-px4video.rules $out/etc/udev/rules.d/99-px4video.rules
      '')
    ];
  };
}
