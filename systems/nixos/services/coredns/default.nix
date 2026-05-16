{ ... }:
{
  services.coredns = {
    enable = true;
    config = ''
      .:53 {
        forward . 8.8.8.8 1.1.1.1
        log
        errors
      }
    '';
  };
}
