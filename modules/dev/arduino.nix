{ config, pkgs, lib, ... }:

let cfg = config.vital.programs.arduino;

  opencr-udev = pkgs.writeTextFile {
      name = "opencr-udev-rules";
      executable = false;
      destination = "/etc/udev/rules.d/99-opencr-cdc.rules";
      text = ''
        # http://linux-tips.org/t/prevent-modem-manager-to-capture-usb-serial-devices/284/2.
        # cp rules /etc/udev/rules.d/
        # sudo udevadm control --reload-rules
        # sudo udevadm trigger

        ATTRS{idVendor}=="0483" ATTRS{idProduct}=="5740", ENV{ID_MM_DEVICE_IGNORE}="1", MODE:="0666"
        ATTRS{idVendor}=="0483" ATTRS{idProduct}=="df11", MODE:="0666"
        ATTRS{idVendor}=="fff1" ATTRS{idProduct}=="ff48", ENV{ID_MM_DEVICE_IGNORE}="1", MODE:="0666"
        ATTRS{idVendor}=="10c4" ATTRS{idProduct}=="ea60", ENV{ID_MM_DEVICE_IGNORE}="1", MODE:="0666"
      '';
    };

in {
  options.vital.programs.arduino = with lib; {
    enable = lib.mkEnableOption "Enable arduino development environment";
    supportOpenCR = lib.mkEnableOption "Whether to add the suport for OpenCR board";
  };
  
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      arduino
    ];

    # Need special udev rules for OpenCR board.
    # See https://emanual.robotis.com/docs/en/parts/controller/opencr10/#usb-port-settings
    services.udev.packages = lib.lists.optionals cfg.supportOpenCR [ opencr-udev ];
  };
}
