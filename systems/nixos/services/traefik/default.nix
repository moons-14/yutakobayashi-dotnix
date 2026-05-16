{ config, lib, ... }:

let
  domain = "www.mod.gov.cn";
in
{
  services.traefik = {
    enable = true;

    staticConfigOptions = {
      entryPoints = {
        web = {
          address = ":80";
          http.redirections.entrypoint = lib.mkForce null;
        };
        websecure = {
          address = ":443";
          http.tls.certResolver = "letsencrypt";
        };
      };

      certificatesResolvers.letsencrypt.acme = {
        email = "hi@yutakobayashi.com";
        storage = "${config.services.traefik.dataDir}/acme.json";
        httpChallenge.entryPoint = "web";
      };

      api.dashboard = true;
    };

    dynamicConfigOptions = {
      http = {
        middlewares = {
          redirect-to-https = {
            redirectscheme = {
              scheme = "https";
              permanent = true;
            };
          };
        };

        routers = {
          https-redirect = {
            entryPoints = [ "web" ];
            rule = "HostRegexp(`{host:.+}`)";
            middlewares = [ "redirect-to-https" ];
            priority = 1;
            service = "noop";
          };

          "mitm-${domain}" = {
            entryPoints = [ "web" ];
            rule = "Host(`${domain}`)";
            priority = 100;
            service = "mitmproxy";
          };
        };

        services = {
          noop = {
            loadBalancer = {
              servers = [ { url = "http://127.0.0.1:1"; } ];
            };
          };
          mitmproxy = {
            loadBalancer = {
              servers = [ { url = "http://127.0.0.1:8081"; } ];
            };
          };
        };
      };
    };
  };
}
