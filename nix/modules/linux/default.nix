{ ... }:

{
  imports = [
    ./nix.nix
    ./packages.nix
    ./ssh.nix
    ./fonts.nix
    ./ipfs.nix
    ./programs/obs-studio.nix
    ./user.nix
    ./locale.nix
  ];
}
