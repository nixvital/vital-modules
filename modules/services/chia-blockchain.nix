{ config, pkgs, lib, ... }:

let cfg = config.vital.services.chia-blockchain;

    containerName = "chiabox";

    chiafunc = pkgs.writeShellScriptBin "chiafunc" ''
      state=$(docker inspect -f "{{.State.Status}}" ${containerName})
      if [ $state != "running" ]; then
        echo "Please make sure that the chia docker container is running."
        exit -1
      fi
      docker exec -it ${containerName} venv/bin/chia $@
    '';

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

    dotchiaDirectory = mkOption {
      type = lib.types.str;
      description = ''
        Specify the path to the directory that saves the state of chia.
        
        This will be mount to /root/.chia inside the docker container.
      '';
      default = "";
      example = "/opt/chia/dotchia";
    };
  };
  
  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.virtualisation.docker.enable;
        message = "Chia-blockchain requires docker to be enabled.";
      }
    ];

    virtualisation.oci-containers.containers."${containerName}" = {
      image = "ghcr.io/chia-network/chia:1.1.2";
      volumes = (lib.optionals (cfg.plotsDirectory != "") [ "${cfg.plotsDirectory}:/plots" ]) ++
                (lib.optionals (cfg.plottingDirectory != "") [ "${cfg.plottingDirectory}:/plotting" ]) ++
                (lib.optionals (cfg.dotchiaDirectory != "") [ "${cfg.dotchiaDirectory}:/root/.chia" ]);
    };

    environment.systemPackages = [ chiafunc ];

    networking.firewall.allowedTCPPorts = [ 8444 ];
  };
}
