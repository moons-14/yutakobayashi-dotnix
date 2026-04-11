# X870-Stell-Legend-WiFi WSL ホスト固有の設定
{ ... }:

{
  # WSL settings
  wsl.enable = true;
  wsl.defaultUser = "yuta";
  wsl.wslConf = {
    automount.options = "metadata";
    boot.systemd = true;
  };
  wsl.useWindowsDriver = true;

  # Networking
  networking.hostName = "X870-Stell-Legend-WiFi";

  system.stateVersion = "25.11";
}
