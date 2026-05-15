{ ... }:

{
  imports = [
    ./terminal.nix
    ../../home/packages.nix
    ../../home/programs/gh.nix
    ../../home/programs/neovim.nix
    ../../home/programs/bat.nix
    ../../home/programs/btop.nix
    ../../home/programs/fastfetch
  ];
}
