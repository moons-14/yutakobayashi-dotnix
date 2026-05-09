{ inputs, mkPkgs }:
let
  inherit (inputs)
    nixpkgs
    home-manager
    nixos-hardware
    ;

  system = "aarch64-linux";
in
nixpkgs.lib.nixosSystem {
  specialArgs = {
    inherit inputs;
  };
  modules = [
    home-manager.nixosModules.home-manager
    nixos-hardware.nixosModules.raspberry-pi-5
    ../../modules/linux/nix.nix
    ../../modules/linux/ssh.nix
    ../../modules/linux/locale.nix
    ./hardware-configuration.nix
    ../../profiles/pi5.nix
    { nixpkgs.pkgs = mkPkgs system; }
    (
      { pkgs, ... }:
      {
        programs.zsh.enable = true;

        users.users.yuta = {
          isNormalUser = true;
          description = "yuta";
          shell = pkgs.zsh;
          extraGroups = [ "wheel" ];
        };

        nix.settings.allowed-users = [ "yuta" ];
        nix.settings.trusted-users = [
          "root"
          "yuta"
        ];

        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          users.yuta = {
            home = {
              username = "yuta";
              homeDirectory = "/home/yuta";
              stateVersion = "25.11";
            };
          };
        };
      }
    )
  ];
}
