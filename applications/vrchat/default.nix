# VRChat / avatar creation toolchain
{ pkgs, lib, ... }:

{
  home.packages =
    (with pkgs; [
      vrc-get
    ])
    ++ lib.optionals pkgs.stdenv.isLinux (
      with pkgs;
      [
        alcom
        blender
        unityhub
        vrcx
      ]
    )
    ++ lib.optionals pkgs.stdenv.isDarwin (
      with pkgs.brewCasks;
      [
        alcom
        blender
      ]
    );
}
