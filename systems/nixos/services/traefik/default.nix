{ config, ... }:

let
  domain = "home.yutakobayashi.com";
in
{
  services.traefik = {
    enable = true;

    staticConfigOptions = {
      entryPoints = {
        web = {
          address = ":80";
        };
      };

      api.dashboard = true;
    };

    dynamicConfigOptions = {
      http = {
        routers = {
          gitea = {
            entryPoints = [ "web" ];
            rule = "Host(`git.${domain}`)";
            service = "gitea";
          };
          grafana = {
            entryPoints = [ "web" ];
            rule = "Host(`grafana.${domain}`)";
            service = "grafana";
          };
          nextcloud = {
            entryPoints = [ "web" ];
            rule = "Host(`cloud.${domain}`)";
            service = "nextcloud";
          };
          immich = {
            entryPoints = [ "web" ];
            rule = "Host(`photos.${domain}`)";
            service = "immich";
          };
          home-assistant = {
            entryPoints = [ "web" ];
            rule = "Host(`ha.${domain}`)";
            service = "home-assistant";
          };
          atuin = {
            entryPoints = [ "web" ];
            rule = "Host(`atuin.${domain}`)";
            service = "atuin";
          };
        };

        services = {
          gitea.loadBalancer.servers = [ { url = "http://localhost:3000"; } ];
          grafana.loadBalancer.servers = [
            { url = "http://localhost:${toString config.services.grafana.settings.server.http_port}"; }
          ];
          nextcloud.loadBalancer.servers = [ { url = "http://localhost:80"; } ];
          immich.loadBalancer.servers = [ { url = "http://localhost:2283"; } ];
          home-assistant.loadBalancer.servers = [
            { url = "http://localhost:${toString config.services.home-assistant.config.http.server_port}"; }
          ];
          atuin.loadBalancer.servers = [
            { url = "http://localhost:${toString config.services.atuin.port}"; }
          ];
        };
      };
    };
  };
}
