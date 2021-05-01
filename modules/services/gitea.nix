{ config, lib, ... }:

let cfg = config.vital.services.gitea;

in {
  options.vital.services.gitea = {
    enable = lib.mkEnableOption "enable the gitea service.";
    domain = lib.mkOption {
      type = lib.types.str;
      description = "The domain name on which gitea is served.";
      example = "git.example.org";
    };
    port = lib.mkOption {
      type = lib.types.port;
      description = "The port on which gitea is served.";
      example = 5965;
    };
    useSSL = lib.mkOption {
      type = lib.types.bool;
      description = "Serve with HTTPS when set to true.";
      default = true;
      example = true;
    };
    appName = lib.mkOption {
      type = lib.types.str;
      description = "The title for the website and on the browser tab.";
      default = "Gitea: Break and Shan";
      example = "My Git Repos";
    };
    landingPage = lib.mkOption {
      type = lib.types.enum [ "home" "explore" "organization" ];
      description = "Landing page for unauthenticated users";
      default = "explore";
      example = "home";
    };
  };

  config = lib.mkIf cfg.enable {
    services.gitea = {
      enable = true;
      appName = cfg.appName;
      user = "git";
      
      # Hint browser to only send cookies via HTTPS
      # cookieSecure = true;
      domain = cfg.domain;
      httpPort = cfg.port;
      # NOTE(breakds): This is only for showing some information on
      # the website, e.g. instructions on how to access the repository
      # when it is first created.
      rootUrl = "http${if cfg.useSSL then "s" else ""}://${cfg.domain}";

      database = {
        user = "git";
        type = "sqlite3";
        path = "/var/lib/gitea/data/gitea.db";
      };
      
      repositoryRoot = "${config.services.gitea.stateDir}/repos";

      # TODO(breakds): Enable the dump (backup), preferrably weekly.

      settings = {
        repository = {
          DISABLE_HTTP_GIT = false;
          USE_COMPAT_SSH_URI = true;         
        };

        security = {
          INSTALL_LOCK = true;
          COOKIE_USERNAME = "gitea_username";
          COOKIE_REMEMBER_NAME = "gitea_userauth";
        };

        servert = {
          LANDING_PAGE = "explore";
        };
      };
    };

    services.nginx.virtualHosts = lib.mkIf config.services.nginx.enable {
      "${cfg.domain}" = {
        enableACME = cfg.useSSL;
        forceSSL = cfg.useSSL;
        locations."/".proxyPass = "http://localhost:${toString cfg.port}";
      };
    };
    
    networking.firewall.allowedTCPPorts = [ config.services.gitea.httpPort ];
  };
}
