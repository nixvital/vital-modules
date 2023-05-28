{ config, lib, pkgs, ... }:

{
  i18n = {
    # Input Method
    inputMethod = {
      enabled = "fcitx5";
      fcitx5.addons = with pkgs; [
        fcitx5-chinese-addons  # This provides pinyin
        fcitx5-gtk
      ];
    };
  };

  # Manually add the systemd service before the following fix is
  # backported to 21.05 branch.
  #
  # https://github.com/NixOS/nixpkgs/commit/195b26b95e2ae8a0c9ee7cb9c1e3d9faf6222d03#diff-8860fb43dd14113fb11b560f06eae265ae29247e8e2bfcaf4981ab1ccbedb24b
  #
  # TODO(breakds): Remove this after the fix is backported.

  systemd.user.services.fcitx5-daemon = {
    enable = true;
    script = "${config.i18n.inputMethod.package}/bin/fcitx5";
    wantedBy = [ "graphical-session.target" ];
  };
}
