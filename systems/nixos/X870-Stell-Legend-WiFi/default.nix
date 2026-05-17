{ inputs, ... }:

{
  imports = [
    inputs.nixos-wsl.nixosModules.default
    ../common.nix
    ../../../nix/modules/profiles/nixos/cli.nix
    (
      { pkgs, ... }:
      {
        environment.systemPackages = [ pkgs.cudatoolkit ];
      }
    )
  ];

  wsl.enable = true;
  wsl.defaultUser = "yuta";
  wsl.wslConf = {
    automount.options = "metadata";
    boot.systemd = true;
  };
  wsl.useWindowsDriver = true;

  networking.hostName = "X870-Stell-Legend-WiFi";

  my.services.tailscale.enable = false;

  system.stateVersion = "25.11";
}
