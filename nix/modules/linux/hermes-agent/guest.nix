{
  config,
  pkgs,
  ...
}:
let
  hermesConfigFile = pkgs.writeText "hermes-config.yaml" (
    builtins.toJSON config.services.hermes-agent.settings
  );
  credentialsDir = "/run/credentials/@system";
in
{
  microvm = {
    vcpu = 2;
    mem = 4096;

    interfaces = [
      {
        type = "user";
        id = "hermes-net";
        mac = "02:00:00:00:48:01";
      }
    ];

    shares = [
      {
        source = "/nix/store";
        mountPoint = "/nix/.ro-store";
        tag = "ro-store";
        proto = "virtiofs";
      }
    ];

    volumes = [
      {
        image = "state.img";
        mountPoint = "/var/lib/hermes";
        size = 4096;
        label = "hermes-state";
      }
    ];
  };

  services.hermes-agent = {
    enable = true;

    settings = {
      model.provider = "openai-codex";

      slack = {
        channel_prompts = { };
      };
    };
  };

  systemd.services.hermes-agent-secrets-seed = {
    description = "Seed hermes-agent config and secrets from systemd credentials";
    wantedBy = [ "hermes-agent.service" ];
    before = [ "hermes-agent.service" ];
    unitConfig.RequiresMountsFor = [ "/var/lib/hermes" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      install -d -o hermes -g hermes -m 2770 /var/lib/hermes/.hermes

      install -o hermes -g hermes -m 0640 \
        ${hermesConfigFile} /var/lib/hermes/.hermes/config.yaml

      install -o hermes -g hermes -m 0640 \
        ${credentialsDir}/hermes-agent.env /var/lib/hermes/.hermes/.env

      if [ ! -f /var/lib/hermes/.hermes/auth.json ]; then
        install -o hermes -g hermes -m 0600 \
          ${credentialsDir}/hermes-agent.auth.json /var/lib/hermes/.hermes/auth.json
      fi
    '';
  };

  services.journald.extraConfig = ''
    ForwardToConsole=yes
    MaxLevelConsole=info
  '';

  system.stateVersion = "25.11";
}
