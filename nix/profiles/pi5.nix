{ ... }:
{
  imports = [
    ./cli-minimal.nix
  ];

  home-manager.users.yuta.imports = [
    ./../modules/home/programs/zsh.nix
    ./../modules/home/programs/git.nix
    ./../modules/home/programs/tmux
  ];
}
