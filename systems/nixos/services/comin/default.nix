{
  imports = [
    ../alloy
    ./alloy.nix
  ];

  services.comin = {
    enable = true;
    exporter.openFirewall = true;
    remotes = [
      {
        name = "origin";
        url = "https://github.com/yutakobayashidev/dotnix";
      }
    ];
  };
}
