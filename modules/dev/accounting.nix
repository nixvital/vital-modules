{ config, pkgs, lib, ... }:

let cfg = config.vital.programs.accounting;

in {
  options.vital.programs.accounting = with lib; {
    enable = lib.mkEnableOption "Enable beancount powered accounting module";
  };
  
  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      beancount fava
    ];
  };
}
