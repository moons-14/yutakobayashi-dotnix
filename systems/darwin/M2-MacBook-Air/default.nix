{ username, ... }:

{
  imports = [
    ./configuration.nix
    ../../../nix/modules/profiles/darwin
    (
      { ... }:
      {
        users.users.${username}.home = "/Users/${username}";

        nix.settings.trusted-users = [
          "root"
          username
        ];
      }
    )
  ];
}
