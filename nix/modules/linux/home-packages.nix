# Linux固有パッケージ
{ pkgs, ... }:

{
  home.packages = with pkgs; [
    # Overlay packages (Linux-only)
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

    # Browsers & Communication (Nix管理)
    google-chrome
    discord
    signal-desktop
    slack

    # Productivity (Nix管理)
    stable.anki
    _1password-gui
    insomnia
    libreoffice
    nextcloud-client

    # Media
    kooha
    spotify

    # Wayland Tools
    rofi
    cliphist
    wl-clipboard
    swww
    grimblast
    swappy
    zenity

    # Screen Management
    brightnessctl

    # System Tools
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
