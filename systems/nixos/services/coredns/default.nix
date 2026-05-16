{ config, lib, ... }:

let
  domain = "www.mod.gov.cn";
in
{
  services.coredns = {
    enable = true;
    config = ''
      .:53 {
        forward . 8.8.8.8 1.1.1.1
        log
        errors
      }
      ${domain}:53 {
        hosts {
          ${domain} ${config.networking.hostName}
        }
        log
      }
    '';
  };
}
