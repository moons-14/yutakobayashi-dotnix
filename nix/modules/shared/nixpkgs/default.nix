{ config, lib, ... }:

let
  cfg = config.my.nixpkgs;
in
{
  options.my.nixpkgs = {
    enable = lib.mkEnableOption "Nixpkgs configuration";
    allowUnfree = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to allow unfree packages.";
    };
    acceptAndroidSdkLicense = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to accept the Android SDK license.";
    };
  };

  config = lib.mkIf cfg.enable {
    nixpkgs.config = {
      allowUnfree = cfg.allowUnfree;
      android_sdk.accept_license = cfg.acceptAndroidSdkLicense;
    };
  };
}
