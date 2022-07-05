{ config, lib, pkgs, ... }:

let cfg = config.vital.programs.texlive;

in {
  options.vital.programs.texlive = with lib; {
    enable = mkEnableOption "Enable texlive suite for TeX development";
  };
  
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.texlive.combined.scheme-full ];
  };
}
