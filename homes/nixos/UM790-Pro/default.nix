{ username, ... }:

{
  imports = [ ../common.nix ];

  home-manager.users.${username} = {
    imports = [
      ../../../nix/modules/profiles/home/cli.nix
      ../../../nix/modules/profiles/home/development.nix
      ../../../nix/modules/profiles/home/desktop.nix
      ../../../nix/modules/linux/programs/niri.nix
      ../../../nix/modules/linux/programs/waybar.nix
      ../../../nix/modules/linux/services/swayidle.nix
      ../../../nix/modules/linux/programs/swaylock.nix
    ];
    home.homeDirectory = "/home/${username}";
  };
}
