{ lib, pkgs, ... }:

let
  isLinux = pkgs.stdenv.isLinux;
in
{
  config = lib.mkIf isLinux {
    programs.obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        droidcam-obs
        obs-backgroundremoval
        obs-gstreamer
        obs-pipewire-audio-capture
        wlrobs
      ];
    };
  };
}
