{ ... }:
{
  imports = [
    ./cli.nix
    ../../linux/pam.nix
    ../../linux/services/bluetooth.nix
    ../../linux/android.nix
    ../../linux/services/networking.nix
    ../../linux/services/printing.nix
  ];
}
