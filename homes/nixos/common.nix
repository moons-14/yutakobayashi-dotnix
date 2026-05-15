{ inputs, ... }:

{
  imports = [
    inputs.home-manager.nixosModules.home-manager
    ../common.nix
  ];
}
