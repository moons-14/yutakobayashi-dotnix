{ inputs, ... }:

{
  imports = [
    inputs.nixos-wsl.nixosModules.default
    ../../../nix/modules/linux
    ./hardware-configuration.nix
    ../../../nix/modules/profiles/nixos/cli.nix
    (
      { pkgs, ... }:
      {
        environment.systemPackages = [ pkgs.cudatoolkit ];
      }
    )
  ];
}
