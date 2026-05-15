{ ... }:
{
  imports = [
    ../../linux/services/docker.nix
    # Tailscaleは含めない
  ];
}
