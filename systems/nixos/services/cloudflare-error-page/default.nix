{ ... }:

let
  errorPagePort = 5000;
in
{
  virtualisation.oci-containers.containers.cloudflare-error-page = {
    image = "ghcr.io/fa0311/cloudflare-error-page-docker:latest";
    ports = [ "127.0.0.1:${toString errorPagePort}:5000" ];
  };
}
