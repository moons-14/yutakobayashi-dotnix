{ ... }:

{
  imports = [
    ./terminal.nix
    ../../home/cli/packages.nix
    ../../home/development/gh.nix
    ../../home/development/neovim.nix
    ../../home/cli/bat.nix
    ../../home/cli/btop.nix
    ../../home/cli/fastfetch
  ];
}
