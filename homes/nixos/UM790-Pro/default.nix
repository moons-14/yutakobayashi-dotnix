{ username, ... }:

{
  imports = [ ../common.nix ];

  home-manager.users.${username} = {
    imports = [
      ../../../nix/modules/profiles/home/cli.nix
      ../../../nix/modules/profiles/home/development.nix
      ../../../nix/modules/profiles/home/desktop.nix
      ../../../applications/niri
      ../../../applications/waybar
      ../../../applications/swayidle
      ../../../applications/swaylock
    ];
    home.homeDirectory = "/home/${username}";
  };
}
