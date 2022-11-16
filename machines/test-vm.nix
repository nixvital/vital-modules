{ config, lib, pkgs, ... }:

{
  imports = [
    ../foundations
    ../modules/addons/docker.nix
    ../modules/addons/laptop.nix
    ../modules/addons/iphone-connect.nix
  ];

  config = {
    vital.mainUser = "tester";
    vital.graphical.enable = true;
    vital.graphical.remote-desktop.enable = true;

    vital.pre-installed.level = 5;
    
    vital.games.steam.enable = true;

    vital.programs.vscode.enable = true;
    vital.programs.arduino.enable = true;
    vital.programs.texlive.enable = true;
    vital.programs.modern-utils.enable = true;
    vital.programs.accounting.enable = true;

    services.nginx.enable = true;
    security.acme = {
      acceptTerms = true;
      email = "sample@example.com";
    };

    vital.services.docker-registry.enable = true;
    vital.services.filerun = {
      enable = true;
      domain = "filerun.example.com";
    };

    vital.services.gitea = {
      enable = true;
      domain = "gitea.example.com";
      port = 5965;
    };

    vital.services.chia-blockchain = {
      enable = true;
    };
    
    networking.hostName = "testvm";
    networking.hostId = "4ca9a368";
  };
}
