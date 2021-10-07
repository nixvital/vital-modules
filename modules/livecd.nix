{ config, pkgs, lib, ... }:

{
  imports = [
    ./dev/modern-utils.nix
  ];

  config = {
    nixpkgs.config.allowUnfree = true;   

    nix = {
      package = pkgs.nixFlakes;
      # Enable flakes
      extraOptions = ''
        experimental-features = nix-command flakes
      '';
    };

    services.xserver.videoDrivers = [ "nvidia" ];

    environment.systemPackages = with pkgs; [
      emacs
    ];
  };
}
