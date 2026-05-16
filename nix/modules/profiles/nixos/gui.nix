{ ... }:
{
  imports = [
    ./cli.nix
    ../../nixos/pam.nix
    ../../nixos/services/bluetooth.nix
    ../../nixos/services/networking.nix
    ../../nixos/services/printing.nix
  ];
}
