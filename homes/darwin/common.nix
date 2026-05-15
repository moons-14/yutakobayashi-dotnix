{ inputs, ... }:

{
  imports = [
    inputs.home-manager.darwinModules.home-manager
    ../common.nix
  ];

  home-manager.backupFileExtension = "hm-bak";
}
