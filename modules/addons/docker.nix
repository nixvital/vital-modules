{ config, pkgs, ... }:

{
  # Enable docker
  virtualisation.docker = {
    enable = true;
    package = pkgs.docker;

    enableNvidia = config.vital.graphical.nvidia.enable;
  };
}
