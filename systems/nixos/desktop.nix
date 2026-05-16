# NixOS desktop settings shared by graphical hosts.
{
  inputs,
  pkgs,
  ...
}:

{
  imports = [
    inputs.nix-hazkey.nixosModules.hazkey
  ];

  programs.niri = {
    enable = true;
  };

  programs.obs-studio.enableVirtualCamera = true;
  programs.xwayland.enable = true;

  environment.systemPackages = with pkgs; [
    wofi
  ];

  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  services.printing.enable = true;

  services.greetd.enable = true;
  programs.regreet.enable = true;

  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";
    fcitx5 = {
      waylandFrontend = true;
      addons = with pkgs; [
        fcitx5-gtk
      ];
      settings = {
        globalOptions = {
          "Hotkey/TriggerKeys"."0" = "Control+space";
        };
        inputMethod = {
          "Groups/0" = {
            Name = "Default";
            "Default Layout" = "us";
            DefaultIM = "hazkey";
          };
          "Groups/0/Items/0".Name = "keyboard-us";
          "Groups/0/Items/1".Name = "hazkey";
          GroupOrder."0" = "Default";
        };
      };
    };
  };

  services.hazkey.enable = true;

  my.security.yubikey.enable = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  fonts = {
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-color-emoji
      inter
      stable.jetbrains-mono
      nerd-fonts.jetbrains-mono
    ];

    fontconfig = {
      defaultFonts = {
        sansSerif = [
          "Inter"
          "Noto Sans CJK JP"
        ];
        serif = [ "Noto Serif CJK JP" ];
        monospace = [ "JetBrains Mono" ];
      };

      # macOS風レンダリング
      antialias = true;
      hinting = {
        enable = true;
        style = "slight";
      };
      subpixel = {
        rgba = "rgb";
        lcdfilter = "default";
      };
    };
  };
}
