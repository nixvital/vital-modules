{ config, lib, pkgs, ... }:

let cfg = config.vital.graphical;

    types = lib.types;

    xserverOptions = {
      options = {
        displayManager = lib.mkOption {
          type = types.enum [ "gdm" "sddm" "lightdm" ];
          default = "gdm";
          description = ''
            To use gdm or sddm for the display manager.
            Values can be "gdm" or "sddm".
          '';
        };
        dpi = lib.mkOption {
          type = types.nullOr types.ints.positive;
          default = null;
          description = "DPI resolution to use for x server.";
        };
        useCapsAsCtrl = lib.mkEnableOption ''
          If enabled, caps lock will be used as an extral Ctrl key.
          Most useful for laptops.
        '';
      };
    };

in {
  imports = [
    ./nvidia.nix
    ./cjk.nix
    ./remote-desktop.nix
  ];
  
  options.vital.graphical = {
    enable = lib.mkEnableOption "Enable Graphical UI (xserver and friends)";
    xserver = lib.mkOption {
      description = "Wrapper of xserver related configuration.";
      type = types.submodule xserverOptions;
      default = {
        displayManager = "gdm";
        dpi = null;
        useCapsAsCtrl = false;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # Enable unfree as it can potentially use Nvidia drivers.
    nixpkgs.config.allowUnfree = true;
    
    # Disable the gnome shell as it is not currently used, and will appear
    # in the dmenu so that hinder how chrome is being launched.
    services.gnome.chrome-gnome-shell.enable = false;

    services.xserver = {
      enable = true;
      layout = "us";
      xkbOptions = "eurosign:e" + (if cfg.xserver.useCapsAsCtrl then ", ctrl:nocaps" else "");

      # DPI
      dpi = cfg.xserver.dpi;

      # Enable touchpad support
      libinput.enable = true;

      # Default desktop manager: gnome.
      desktopManager.gnome.enable = true;
      desktopManager.gnome.extraGSettingsOverrides = ''
        [org.gnome.desktop.peripherals.touchpad]
        click-method='default'
      '';

      displayManager.gdm.enable = cfg.xserver.displayManager == "gdm";
      # When using gdm, do not automatically suspend since we want to
      # keep the server running.
      displayManager.gdm.autoSuspend = false;
      displayManager.sddm.enable = cfg.xserver.displayManager == "sddm";
      displayManager.lightdm.enable = cfg.xserver.displayManager == "lightdm";
    };

    # Exclude some of the gnome3 packages
    programs.geary.enable = false;    
    environment.gnome.excludePackages = with pkgs.gnome3; [
      epiphany
      gnome-software
      gnome-characters
    ];

    # Font
    fonts.fonts = with pkgs; [
      # Add Wenquanyi Microsoft Ya Hei, a nice-looking Chinese font.
      wqy_microhei
      # Fira code is a good font for coding
      fira-code
      fira-code-symbols
      font-awesome
      inconsolata
    ];

    console = {
      packages = [ pkgs.wqy_microhei pkgs.terminus_font  ];
      font = "ter-132n";
    };

    hardware.opengl.setLdLibraryPath = true;
  };
}
