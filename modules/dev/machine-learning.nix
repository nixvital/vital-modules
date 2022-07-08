# Provides configurations that supports running and maintaining machine learning
# experiments.

{ config, pkgs, lib, ... }:

let cfg = config.vital.programs.machine-learning;

in {
  options.vital.programs.machine-learning = with lib; {
    enable = mkEnableOption "Enable machine learning utilities and configs";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      nvitop
    ];
  };
}
