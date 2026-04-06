{ inputs, mkPkgs }:
let
  inherit (inputs)
    nixpkgs
    home-manager
    nixos-wsl
    nix-filter
    ;

  system = "x86_64-linux";

  helpers = import ../../modules/lib/helpers { lib = nixpkgs.lib; };
  dotfilesDir = "/home/yuta/ghq/github.com/yutakobayashidev/dotnix";

  local-skills = nix-filter.lib {
    root = inputs.self;
    include = [ "agents/skills" ];
  };
in
nixpkgs.lib.nixosSystem {
  inherit system;
  specialArgs = {
    inherit inputs;
    username = "yuta";
  };
  modules = [
    home-manager.nixosModules.home-manager
    nixos-wsl.nixosModules.default
    ../../modules/linux
    ./hardware-configuration.nix
    ../../profiles/cli.nix
    { nixpkgs.pkgs = mkPkgs system; }
    (
      { pkgs, ... }:
      {
        environment.systemPackages = [ pkgs.xdg-utils ];

        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = {
            inherit
              inputs
              helpers
              dotfilesDir
              local-skills
              ;
          };
          sharedModules = [
            inputs.agent-skills.homeManagerModules.default
            inputs.nix-index-database.homeModules.nix-index
          ];
          users.yuta = {
            imports = [ ../../modules/home ];
            home.homeDirectory = "/home/yuta";
            home.file.".local/share/applications/file-protocol-handler.desktop".text = ''
              [Desktop Entry]
              Type=Application
              Version=1.0
              Name=File Protocol Handler
              NoDisplay=true
              MimeType=x-scheme-handler/http;x-scheme-handler/https;
              Exec=rundll32.exe url.dll,FileProtocolHandler %u
            '';
            xdg.configFile."mimeapps.list".text = ''
              [Default Applications]
              x-scheme-handler/http=file-protocol-handler.desktop
              x-scheme-handler/https=file-protocol-handler.desktop

              [Added Associations]
              x-scheme-handler/http=file-protocol-handler.desktop;
              x-scheme-handler/https=file-protocol-handler.desktop;
            '';
          };
        };
      }
    )
  ];
}
