{ config, pkgs, lib, ... }:

let cfg = config.vital.services.chia-blockchain;

in {
  options.vital.services.chia-blockchain = with lib; {
    enable = mkEnableOption "Enable this to start a chia-network node in docker";

    plotsDirectory = mkOption {
      type = lib.types.str;
      description = ''
        Specify the path to the directory that has all the plots.
        
        This will be mount to /plots inside the docker container.
      '';
      default = "";
      example = "/opt/chia/plots";
    };

    plottingDirectory = mkOption {
      type = lib.types.str;
      description = ''
        Specify the path to the directory that serves as temporary directory while plotting.
        
        This will be mount to /plotting inside the docker container.

        Note that the faster the disk (nvme) the better performance you will have for plotting.
      '';
      default = "";
      example = "/opt/chia/plots";
    };
  };
  
  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.virtualisation.docker.enable;
        message = "Chia-blockchain requires docker to be enabled.";
      }
    ];

    virtualisation.oci-containers.containers."chiabox" = {
      image = "ghcr.io/chia-network/chia:1.1.2";
      volumes = (lib.optionals (cfg.plotsDirectory != "") [ "${cfg.plotsDirectory}:/plots" ]) ++
                (lib.optionals (cfg.plottingDirectory != "") [ "${cfg.plottingDirectory}:/plotting" ]);
    };
  };
}
