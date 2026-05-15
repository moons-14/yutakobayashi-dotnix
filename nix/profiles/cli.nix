{ ... }:
{
  imports = [
    ./cli-minimal.nix
    ./../modules/linux/services/docker.nix
    ./../modules/linux/services/tailscale.nix
  ];

  home-manager.users.yuta.imports = [
    ./../modules/home/programs/common-cli.nix
    ./../modules/linux/home-packages.nix
  ];
}
