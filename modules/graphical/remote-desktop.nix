{ config, pkgs, lib, ... } :

let cfg = config.vital.graphical.remote-desktop;

in {

  options.vital.graphical.remote-desktop = with lib; {
    enable = mkEnableOption "Whether to enable the XRDP server";
    port = mkOption {
      type = types.port;
      description = "Port for the XRDP server";
      default = 3389;
    };
  };


  config = lib.mkIf (config.vital.graphical.enable && cfg.enable) {
    # Use xfce for the remote desktop.
    services.xserver.desktopManager.xfce.enable = true;
    
    services.xrdp = {
      enable = true;
      defaultWindowManager = "xfce4-session";
      port = cfg.port;
    };

    networking.firewall.allowedTCPPorts = [ cfg.port ];
  };
}
