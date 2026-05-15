{ ... }:

{
  imports = [
    ./nix.nix
    ./packages.nix
    ./services/ssh.nix
    ./fonts.nix
    ./services/ipfs.nix
    ./services/sudo.nix
    ./programs/obs-studio.nix
    ./user.nix
    ./locale.nix
  ];
}
