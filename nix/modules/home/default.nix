{ ... }:

{
  imports = [
    ../profiles/home/base.nix
    ../profiles/home/cli.nix
    ../profiles/home/development.nix
    ../profiles/home/desktop.nix
  ];

  home.username = "yuta";

  home.stateVersion = "25.11";
}
