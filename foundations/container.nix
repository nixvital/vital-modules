# This is the foundation to be used to make a declarative container.

{ config, lib, pkgs, ... }:

let cfg = config.vital.container;

in {
  options.vital.container = with lib; {
    mainUser = mkOption {
      type = types.str;
      description = "The main user of this NixOS container";
    };
  };

  config = {
    boot.isContainer = true;

    # Allow ssh into this container, but only with the corresponding
    # private key.
    services.openssh = {
      enable = lib.mkDefault true;
      passwordAuthentication = false;
    };

    users.extraUsers."${cfg.mainUser}" = {
      isNormalUser = true;
      home = "/home/${cfg.mainUser}";
      uid = 1000;
      description = "The main user of this NixOS container";
      extraGroups = [
        "users"
        "wheel" # Allow sudo
        "networkmanager"
        "nginx"
      ];
    };

    # Allow the user to sudo without typing password
    security.sudo.extraRules = [
      {
        users = [ "${cfg.mainUser}" ];
        commands = [ { command = "ALL"; options = [ "NOPASSWD" ];} ];
      }
    ];
  };
}
