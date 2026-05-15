{ ... }:
{
  imports = [
    ./cli.nix
    ./../modules/linux/niri.nix
    ./../modules/linux/input.nix
    ./../modules/linux/pam.nix
    ./../modules/linux/services/audio.nix
    ./../modules/linux/services/bluetooth.nix
    ./../modules/linux/android.nix
    ./../modules/linux/services/networking.nix
    ./../modules/linux/services/printing.nix
  ];

  home-manager.users.yuta.imports = [
    ./../modules/linux/programs/niri.nix
    ./../modules/linux/programs/waybar.nix
    ./../modules/home/programs/ghostty
    ./../modules/linux/services/swayidle.nix
    ./../modules/linux/programs/swaylock.nix
  ];
}
