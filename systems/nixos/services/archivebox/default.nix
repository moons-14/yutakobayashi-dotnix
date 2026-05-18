{
  ...
}:

let
  archiveboxPort = 8000;
in
{
  virtualisation.oci-containers.containers.archivebox = {
    image = "ghcr.io/archivebox/archivebox:main";
    ports = [ "127.0.0.1:${toString archiveboxPort}:8000" ];
    volumes = [
      "/mnt/usb/services/archivebox/data:/data"
    ];
    environment = {
      ALLOWLIST_HOSTS = "localhost,127.0.0.1,archive.home.yutakobayashi.com";
      CSRF_TRUSTED_ORIGINS = "http://127.0.0.1:${toString archiveboxPort},http://archive.home.yutakobayashi.com";
      REVERSE_PROXY_USER_HEADER = "X-Remote-User";
      REVERSE_PROXY_WHITELIST = "127.0.0.1/32,100.86.129.23/32";
    };
  };
}
