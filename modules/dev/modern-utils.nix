# This provides a list utilities that does the job better than its
# unix ancestors.

{ config, pkgs, lib, ... }:

let cfg = config.vital.programs.modern-utils;

in {
  options.vital.programs.modern-utils = with lib; {
    enable = mkEnableOption "Enable modern linux utilities";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      xh                # Modern curl
      tldr              # Minimalism mam
      procs             # Modern ps
      glances           # Modern htop (but slower)
      fd                # Modern find
      silver-searcher   # Modern ack
      duf               # Modern df
      du-dust           # Modern du
      lsd               # Modern ls
      bat               # Modern cat
    ];
  };
}
