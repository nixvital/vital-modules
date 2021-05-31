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

    port = lib.mkOption {
      type = lib.types.port;
      description = "The port (on host) that status will be served";
      default = 5008;
      example = 5008;
    };

    staggering = lib.mkOption {
      type = lib.types.int;
      description = "Staggering in seconds";
      default = 600;
      example = 600;  # 10 minutes
    };

    forwardConcurrency = lib.mkOption {
      type = lib.types.int;
      description = ''
        Specify the max number of CPUs to use for the stage 1 (Forward) of the plotting.
      '';
      default = 4;
      example = 4;  # 10 minutes
    };

    useChiabox = lib.mkOption {
      type = lib.types.bool;
      description = ''
        If set to false, it will use the native chia instead of chiabox (in the docker).

        In the newer version is recommend to use the native chia, so default to false.
      '';
      default = false;
      example = false;
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = (!cfg.useChiabox) || config.vital.services.chia-blockchain.enable;
        message = "If useChiabox is set to true, you need chia-blockchain service.";
      }
    ];

    systemd.services.chiafan-workforce = {
      description = "Chiafan workforce for plotting";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      path = with pkgs; [
        utillinux
        chia
        docker
        awscli2
      ];

      serviceConfig = {
        Type = "simple";
        ExecStart = ''
          ${pkgs.python3Packages.chiafan-workforce}/bin/chiafan \
              ${lib.strings.concatMapStrings (x: "--worker " + x + " ") cfg.workers} \
              --use_chiabox ${toString (if cfg.useChiabox then 1 else 0)} \
              --farm_key ${cfg.farmKey} \
              --pool_key ${cfg.poolKey} \
              --port ${toString cfg.port} \
              --staggering ${toString cfg.staggering} \
              --forward_concurrency ${toString cfg.forwardConcurrency}
        '';
      };
    };

    # TODO(breakds): Let user specify port
    networking.firewall.allowedTCPPorts = [ cfg.port ];

    # You will likely need to directly call chia as well if you need
    # chiafan-workforce.
    environment.systemPackages = with pkgs; [ chia ];
  };
}
