# Origianlly from
# https://github.com/NixOS/nixpkgs/blob/78af98a068906cb88fa14c31bd703341562bf890/nixos/modules/services/networking/iscsi/target.nix

# This service is used to run a iSCSI target (server) so that it can
# expose block devices via the server.

{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.target;
in
{
  ###### interface
  options = {
    services.target = with types; {
      enable = mkEnableOption "the kernel's LIO iscsi target";

      config = mkOption {
        type = attrs;
        default = {};
        description = ''
          Content of /etc/target/saveconfig.json
          This file is normally read and written by targetcli
        '';
      };

      port = mkOption {
        type = lib.types.port;
        description = "The port on which the iscsi portal serves";
        default = 3260;
        example = 3260;
      };
    };
  };

  ###### implementation
  config = mkIf cfg.enable {
    environment.etc."target/saveconfig.json" = {
      text = builtins.toJSON cfg.config;
      mode = "0600";
    };

    environment.systemPackages = with pkgs; [ targetcli ];

    boot.kernelModules = [ "configfs" "target_core_mod" "iscsi_target_mod" ];

    systemd.services.iscsi-target = {
      enable = true;
      after = [ "network.target" "local-fs.target" ];
      requires = [ "sys-kernel-config.mount" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.python3.pkgs.rtslib}/bin/targetctl restore";
        ExecStop = "${pkgs.python3.pkgs.rtslib}/bin/targetctl clear";
        RemainAfterExit = "yes";
      };
    };

    systemd.tmpfiles.rules = [
      "d /etc/target 0700 root root - -"
    ];

    networking.firewall.allowedTCPPorts = [ cfg.port ];
  };
}
