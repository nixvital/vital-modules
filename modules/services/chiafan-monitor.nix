{ config, pkgs, lib, ... }:

let cfg = config.vital.services.chiafan-monitor;

in {
  options.vital.services.chiafan-monitor = with lib; {
    enable = lib.mkEnableOption "Enable the chiafan monitor service";

    machines = mkOption {
      type = types.listOf types.str;
      description = ''
        A list of ip:port specifying the monitored machines
      '';
      default = [];
      example = [
        "192.168.1.58:5008"
        "192.168.1.59:5008"
      ];
    };

    port = lib.mkOption {
      type = lib.types.port;
      description = "The port (on host) that monitor page will be served";
      default = 5008;
      example = 5008;
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.chiafan-monitor = {
      description = "Chiafan monitor";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      path = with pkgs; [
        utillinux
        docker
        awscli2
      ];

      serviceConfig = {
        Type = "simple";
        ExecStart = ''
          ${pkgs.python3Packages.chiafan-monitor}/bin/chiafan-monitor \
               ${lib.strings.concatMapStrings (x: "--machine " + x + " ") cfg.machines} \
              --port ${toString cfg.port} \
        '';
      };
    };

    # TODO(breakds): Let user specify port
    networking.firewall.allowedTCPPorts = [ cfg.port ];
  };
}
