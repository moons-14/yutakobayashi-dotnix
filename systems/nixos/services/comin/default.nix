{
  imports = [
    ../alloy
    ../../../shared/comin/alloy.nix
  ];

  services.comin = {
    enable = true;
    remotes = [
      {
        name = "origin";
        url = "https://github.com/yutakobayashidev/dotnix";
      }
    ];
  };
}
