{ ... }:
{
  imports = [
    ../../shared/nix
    ../../nixos/services/ssh.nix
    ../../nixos/services/sudo.nix
    ../../nixos/locale.nix
  ];
}
