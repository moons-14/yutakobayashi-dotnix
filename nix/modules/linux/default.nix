{ ... }:

{
  imports = [
    ./packages.nix
    ./services/ssh.nix
    ./services/ipfs.nix
    ./services/sudo.nix
    ./programs/obs-studio.nix
    ./user.nix
    ./locale.nix
  ];
}
