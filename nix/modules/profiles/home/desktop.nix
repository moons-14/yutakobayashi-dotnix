{ lib, pkgs, ... }:

{
  imports = [
    ../../home/vrchat.nix
    ../../home/programs/chromium.nix
    ../../home/programs/firefox.nix
    ../../home/programs/obs-studio.nix
    ../../home/programs/ghostty
  ];

  home.packages =
    with pkgs;
    lib.optionals pkgs.stdenv.isLinux [
      # Overlay packages
      ghostty
      keifu

      # Android
      android-tools
      android-studio

      # YubiKey
      yubikey-manager
      yubioath-flutter
      pam_u2f
      pamtester

      # Browsers & communication
      google-chrome
      discord
      signal-desktop
      slack

      # Productivity
      stable.anki
      _1password-gui
      insomnia
      libreoffice
      nextcloud-client

      # Media
      kooha
      spotify

      # Wayland tools
      rofi
      cliphist
      wl-clipboard
      swww
      grimblast
      swappy
      zenity

      # Screen management
      brightnessctl

      # System tools
      kubo
      rpi-imager
      difit
      binutils
      arp-scan

      # AI / LLM
      lmstudio

      # Misc
      cava
      nautilus
    ];
}
