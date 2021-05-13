{ config, pkgs, lib, ... }:

let cfg = config.vital.services.chiafan-workforce;

in {
  options.vital.services.chiafan-workforce = with lib; {
    enable = lib.mkEnableOption "Enable the chiafan workforce service";

    farmKey = mkOption {
      type = types.str;
      description = ''
        The farmer key of the plots that is being plotted.

        This can be obtained by running `chia keys show`
      '';
      default = "";
      example = "8d3e6ed9dc07e3f38fb7321adc3481a95fbdea515f60ff9737c583c5644c6cf83a5e38e9f3e1fc01d43deef0fa1bd0be";
    };

    poolKey = mkOption {
      type = types.str;
      description = ''
        The pool key of the plots that is being plotted.

        This can be obtained by running `chia keys show`
      '';
      default = "";
      example = "ad0dce731a9ef1813dca8498fa37c3abda52ad76795a8327ea883e6aa6ee023f9e06e9a0d5ea1fa3c625261b9da18f12";
    };

    workers = mkOption {
      type = types.listOf types.str;
      description = ''
        A list of WORKSPACE:DESTINATION
      '';
      default = [];
      example = [
        "/plotting/P01:/plots/F01"
        "/plotting/P02:/plots/F02"
      ];
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.vital.services.chia-blockchain.enable;
        message = "chiafan workforce service requires chia-blockchain enabled.";
      }
    ];

    systemd.services.chiafan-workforce = {
      description = "Chiafan workforce for plotting";
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
          ${pkgs.python3Packages.chiafan-workforce}/bin/chiafan \
               ${lib.strings.concatMapStrings (x: "--worker " + x + " ") cfg.workers} \
              --farm_key ${cfg.farmKey} \
              --pool_key ${cfg.poolKey}
        '';
      };
    };

    # TODO(breakds): Let user specify port
    networking.firewall.allowedTCPPorts = [ 5000 ];
  };
}
