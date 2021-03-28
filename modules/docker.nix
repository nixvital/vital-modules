{ config, pkgs, ... }:

{
  # Enable docker
  virtualisation.docker = {
    enable = true;
    # Cutting edge docker.
    package = pkgs.docker-edge;
  };
}
