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
}
