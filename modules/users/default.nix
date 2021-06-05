{ config, lib, pkgs, ... }:

let cfg = config.vital;

in {

  options.vital = with lib; {
    # There is no default value for mainUser and you have to specify
    # it in order to get a working NixOS machine.
    mainUser = mkOption {
      type = types.str;
      description = "The main user name with uid = 1000";
    };
  };

  config = {
    users = {
      extraUsers = {
        "${cfg.mainUser}" = {
          isNormalUser = true;
          initialHashedPassword = lib.mkDefault "$5$o2c1SrFVg1xK570h$EO3uklJz1y3SbIPJ5zBUdG6ZYNFKoui3EYa5CX/9j0A";
	        home = "/home/${cfg.mainUser}";
          uid = 1000;
	        description = "The main user with uid = 1000";
          extraGroups = [
	          "${cfg.mainUser}"
	          "wheel"  # For sudo
	          "networkmanager"
	          "dialout"  # Access /dev/ttyUSB* devices
	          "uucp"  # Access /ev/ttyS... RS-232 serial ports and devices.
	          "audio"
	          "plugdev"  # Allow members to mount/umount removable devices via pmount.
            "gitea"
	          "lxd"
	          "docker"
            "nginx"
            "samba"
          ];
        };

        # TODO(breakds): Move the other extra users to their own modules.
        fcgi = {
          isSystemUser = true;
          group = "fcgi";
	        extraGroups = [ "fcgi" "git" ];
	        uid = 500;
        };

        nginx = {
          isSystemUser = true;          
          group = "nginx";
          extraGroups = [ "nginx" ];
          uid = 60;
        };

        git = {
          isNormalUser = true;
          group = "git";
          extraGroups = [ "git" "fcgi" "gitea" ];
          uid = 510;
          home = "/home/git";
          description = "User for git server.";
        };
      };

      extraGroups = {
        "${cfg.mainUser}" = { gid = 1000; members = [ "${cfg.mainUser}" ]; };
        fcgi = { gid = 500; members = [ "fcgi" ]; };
        plugdev = { gid = 501; };
        nginx = { gid = 60; members = [ "nginx" ]; };
        git = { gid = 510; members = [ "${cfg.mainUser}" "git" "fcgi" ]; };
        localshare = { gid = 758; members = [ "${cfg.mainUser}" ]; };
      };
    };
  };
}
