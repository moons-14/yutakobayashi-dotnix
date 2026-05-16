{ ... }:
{
  imports = [
    ../../shared/nix
    ../../linux/services/ssh.nix
    ../../linux/services/sudo.nix
    ../../linux/locale.nix
  ];
}
