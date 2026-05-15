{ ... }:
{
  imports = [
    ./cli.nix
    ../../linux/niri.nix
    ../../linux/input.nix
    ../../linux/pam.nix
    ../../linux/services/audio.nix
    ../../linux/services/bluetooth.nix
    ../../linux/android.nix
    ../../linux/services/networking.nix
    ../../linux/services/printing.nix
  ];
}
