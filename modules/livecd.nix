{ config, pkgs, lib, ... }:

{
  imports = [
    ./dev/modern-utils.nix
  ];
  
  config = {
    nix = {
      package = pkgs.nixFlakes;
      # Enable flakes
      extraOptions = ''
        experimental-features = nix-command flakes
      '';
    };

    environment.systemPackages = with pkgs; [
      emacs
    ];
  };
}
