{ inputs, username, ... }:

{
  imports = [ ../common.nix ];

  home-manager.users.${username} =
    { pkgs, ... }:
    {
      imports = [
        ../../../nix/modules/profiles/home/cli.nix
        ../../../nix/modules/profiles/home/development.nix
        ../../../nix/modules/profiles/home/desktop.nix
        ../desktop.nix
        inputs.onepassword-shell-plugins.hmModules.default
      ];
      home.homeDirectory = "/Users/${username}";
      programs._1password-shell-plugins = {
        enable = true;
        plugins = with pkgs; [
          gh
          awscli2
        ];
      };
    };
}
