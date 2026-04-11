# VRChat / avatar creation toolchain
{ pkgs, lib, ... }:

{
  home.packages =
    (with pkgs; [
      vrc-get
      alcom
      blender
    ])
    ++ lib.optionals pkgs.stdenv.isLinux (
      with pkgs;
      [
        unityhub
        vrcx
      ]
    );
}
