{ inputs, pkgs, ... }:

{
  imports = [
    inputs.nix-hazkey.nixosModules.hazkey
  ];

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
}
