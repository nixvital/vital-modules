# TODO(breakds): Needs more update. Also, the current latest version of nocodb
# has bug that fail the update of a column with multi select.
{ config, pkgs, lib, ... }: let
  cfg = config.vital.services.nocodb;
  mysqlPath = "${cfg.workDir}/mysql";
  dataPath = "${cfg.workDir}/data";  
  mysqlContainerName = "nocodb-mysql";
  bridgeNetworkName = "nocodb_network";
  dockercli = "${config.virtualisation.docker.package}/bin/docker";
in {

  options.vital.services.nocodb = {
    enable = lib.mkEnableOption ''
      Enable the NocoDB service. NocoDB is an open source alternative to Airtable.
    '';

    workDir = lib.mkOption {
      type = lib.types.str;
      description = ''
        This specifies the working dir of NocoDB.
      '';
      default = "/var/lib/nocodb";
      example = "/var/lib/nocodb";
    };

    port = lib.mkOption {
      type = lib.types.port;
      description = "The port (on host) that nocodb will be served on.";
      default = 5967;
    };

    domain = lib.mkOption {
      type = lib.types.str;
      description = "The domain to configure nginx for this service.";
      example = "table.example.org";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.tmpfiles.rules = [
      "d ${cfg.workDir} 775 delegator delegator -"
      "d ${mysqlPath} 775 delegator delegator -"
      "d ${dataPath} 775 delegator delegator -"
    ];

    # This is an one-shot systemd service to make sure that the
    # required network is there.
    systemd.services.init-nocodb-network-and-files = {
      description = "Create the network bridge ${bridgeNetworkName} for nocodb.";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig.Type = "oneshot";

      script = ''
        # Put a true at the end to prevent getting non-zero return code, which will
        # crash the whole service.
        check=$(${dockercli} network ls | grep "${bridgeNetworkName}" || true)
        if [ -z "$check" ]; then
          ${dockercli} network create ${bridgeNetworkName}
        else
          echo "${bridgeNetworkName} already exists in docker"
        fi
      '';
    };

    virtualisation.oci-containers.containers."${mysqlContainerName}" = {
      image = "mariadb:10.7";
      environment = {
        "MYSQL_ROOT_PASSWORD" = "password";
        "MYSQL_USER" = "noco";
        "MYSQL_PASSWORD" = "password";
        "MYSQL_DATABASE" = "nocodb_data";
      };
      volumes = [ "${mysqlPath}:/var/lib/mysql" ];
      extraOptions = [ "--network=${bridgeNetworkName}" ];
    };


    virtualisation.oci-containers.containers."nocodb" = {
      image = "nocodb/nocodb:0.84.15";
      environment = {
        "NC_DB" = "mysql2://${mysqlContainerName}:3306?u=noco&p=password&d=nocodb_data";
        "PORT" = "${toString cfg.port}";
      };
      dependsOn = [ "${mysqlContainerName}" ];
      ports = [ "${toString cfg.port}:${toString cfg.port}" ];
      volumes = [ "${dataPath}:/usr/app/data" ];
      extraOptions = [ "--network=${bridgeNetworkName}" ];
    };
  };
}
