{ config, lib, ... }:

let
  domain = "www.mod.gov.cn";
  errorPagePort = 5000;
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
          error-pages = {
            errors = {
              status = [
                "500-599"
                "404"
                "403"
              ];
              query = "/{status}.html";
              service = "error-pages-service";
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
            middlewares = [ "error-pages" ];
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
          error-pages-service = {
            loadBalancer = {
              servers = [ { url = "http://127.0.0.1:${toString errorPagePort}"; } ];
            };
          };
        };
      };
    };
  };
}
