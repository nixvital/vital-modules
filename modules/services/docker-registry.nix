{ config, lib, ... }:

let cfg = config.vital.services.docker-registry;

in {
  options.vital.services.docker-registry = with lib; {
    enable = mkEnableOption "Whether to enable the docker registry service.";
    
    domain = lib.mkOption {
      type = lib.types.str;
      description = "The domain name on which the docker resgistry is served.";
      default = "localhost";
      example = "docker.breakds.org";
    };

    port = lib.mkOption {
      type = lib.types.port;
      description = "The port on which the docker registry is served.";
      default = 5050;
      example = 5050;
    };
  };

  config = lib.mkIf cfg.enable {
    services.dockerRegistry = {
      enable = true;
      # Do not enable redis cache for simplicity.
      enableRedisCache = false;
      enableGarbageCollect = true;
      port = cfg.port;
    };

    networking.firewall.allowedTCPPorts = [ config.services.dockerRegistry.port ];

    services.nginx.virtualHosts = lib.mkIf config.services.nginx.enable {
      "${cfg.domain}" = {
        enableACME = true;
        forceSSL = true;
        locations."/".proxyPass = "http://localhost:${toString cfg.port}";
      };
    };
  };
}
