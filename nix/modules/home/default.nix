{ pkgs, ... }:

{
  imports = [
    ./dotfiles.nix
    ./agent-skills.nix
    ./programs/ai-tools.nix
    ./programs/dev-tools.nix
    ./programs/claude-code.nix
    ./programs/codex.nix
    ./programs/firefox.nix
    ./programs/git.nix
    ./programs/jj.nix
    ./programs/obs-studio.nix
    ./programs/zsh.nix
  ];

  programs.chromium = {
    enable = true;
    package = if pkgs.stdenv.isDarwin then null else pkgs.chromium;
    extensions = [
      { id = "gppongmhjkpfnbhagpmjfkannfbllamg"; } # Wappalyzer
      { id = "hkgfoiooedgoejojocmhlaklaeopbecg"; } # Picture-in-Picture
      { id = "dbepggeogbaibhgnhhndojpepiihcmeb"; } # Vimium
      { id = "cnjifjpddelmedmihgijeibhnjfabmlf"; } # Obsidian Web Clipper
      { id = "aeblfdkhhhdcdjpifhhbdiojplfjncoa"; } # 1Password
      { id = "kpgefcfmnafjgpblomihpgmejjdanjjp"; } # nos2x
      { id = "fcoeoabgfenejglbffodgkkbkcdhcgfn"; } # Claude
      { id = "lkihjlcipnbgeokmfnpogjfflofbfhga"; } # Are.na
      { id = "nkbihfbeogaeaoehlefnkodbefgpgknn"; } # MetaMask
      { id = "nibjojkomfdiaoajekhjakgkdhaomnch"; } # IPFS Companion
      { id = "neebplgakaahbhdphmkckjjcegoiijjo"; } # Keepa
    ];
  };

  # nix-index for command-not-found and comma
  programs.nix-index.enable = true;
  programs.nix-index-database.comma.enable = true;

  home.username = "yuta";

  home.stateVersion = "25.11";
}
