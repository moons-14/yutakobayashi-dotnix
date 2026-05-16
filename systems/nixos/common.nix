{ ... }:

{
  # Base modules shared by regular NixOS hosts. Host-specific profiles still
  # decide whether the machine is desktop, server, or WSL.
  imports = [
    ../../nix/modules/linux
    ../../nix/modules/shared/nix
  ];

  nix.gc.dates = "weekly";

  nix.settings = {
    keep-outputs = true;
    keep-derivations = true;
    connect-timeout = 5;
  };
}
