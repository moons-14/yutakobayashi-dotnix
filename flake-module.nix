{
  inputs,
  lib,
  config,
  mkPkgs,
  ...
}:

let
  inherit (builtins) pathExists;
  inherit (lib)
    filter
    foldl'
    mapAttrsToList
    mkOption
    optionalAttrs
    optionals
    recursiveUpdate
    types
    ;

  getDefaultPlatform = system: if lib.hasSuffix "-linux" system then "nixos" else "darwin";

  maybePath = path: if pathExists path then path else null;

  systemConfigurations =
    platform: hostname: attrs:
    if platform == "nixos" then
      { nixosConfigurations.${hostname} = inputs.nixpkgs.lib.nixosSystem attrs; }
    else if platform == "darwin" then
      { darwinConfigurations.${hostname} = inputs.nix-darwin.lib.darwinSystem attrs; }
    else
      { nixOnDroidConfigurations.${hostname} = inputs.nix-on-droid.lib.nixOnDroidConfiguration attrs; };

  mkSystemConfiguration =
    name: cfg:
    systemConfigurations cfg.platform name (
      {
        modules =
          filter (x: x != null) [
            (maybePath ./systems/${cfg.platform}/${name})
            (maybePath ./homes/${cfg.platform}/${name})
          ]
          ++ cfg.modules
          ++ optionals (cfg.platform != "android") [
            { nixpkgs.pkgs = mkPkgs cfg.system; }
          ];
      }
      // optionalAttrs (cfg.platform != "android") {
        inherit (cfg) system;
        specialArgs = {
          inherit inputs;
          inherit (cfg) username;
        }
        // cfg.specialArgs;
      }
      // optionalAttrs (cfg.platform == "android") {
        extraSpecialArgs = {
          inherit inputs;
          inherit (cfg) username;
        }
        // cfg.specialArgs;
        pkgs = import inputs.nixpkgs {
          inherit (cfg) system;
          overlays = [ inputs.nix-on-droid.overlays.default ];
        };
        home-manager-path = inputs.home-manager.outPath;
      }
    );
in
{
  options.hosts = mkOption {
    default = { };
    type = types.attrsOf (
      types.submodule (
        { name, config, ... }:
        {
          options = {
            system = mkOption {
              default = "x86_64-linux";
              type = types.str;
            };

            platform = mkOption {
              default = getDefaultPlatform config.system;
              type = types.enum [
                "nixos"
                "darwin"
                "android"
              ];
            };

            modules = mkOption {
              default = [ ];
              type = types.listOf types.unspecified;
            };

            username = mkOption {
              default = "yuta";
              type = types.str;
            };

            specialArgs = mkOption {
              default = { };
              type = types.attrs;
            };
          };
        }
      )
    );
  };

  config = rec {
    flake = foldl' recursiveUpdate { } (mapAttrsToList mkSystemConfiguration config.hosts);

    perSystem =
      { lib, system, ... }:
      {
        checks =
          let
            currentSystemConfigurations = lib.filterAttrs (
              _name: value: value.pkgs.stdenv.hostPlatform.system == system
            ) ((flake.nixosConfigurations or { }) // (flake.darwinConfigurations or { }));
          in
          builtins.mapAttrs (_name: value: value.config.system.build.toplevel) currentSystemConfigurations;
      };
  };
}
