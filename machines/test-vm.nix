{ config, lib, pkgs, ... }:

{
  imports = [
    ../foundations
    ../modules/addons/docker.nix
    ../modules/addons/laptop-lids.nix
    ../modules/addons/iphone-connect.nix
  ];

  config = {
    vital.mainUser = "tester";
    vital.graphical.enable = true;
    vital.graphical.remote-desktop.enable = true;

    vital.pre-installed.level = 5;
    
    vital.games.steam.enable = true;

    vital.programs.vscode.enable = true;

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
    
    networking.hostName = "testvm";
    networking.hostId = "4ca9a368";
  };
}
