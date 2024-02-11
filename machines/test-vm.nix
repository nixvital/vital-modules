{ config, lib, pkgs, ... }:

{
  imports = [
    ../foundations
  ];

  config = {
    vital.mainUser = "tester";

    vital.pre-installed.level = 5;
    
    vital.programs.vscode.enable = true;
    vital.programs.arduino.enable = true;
    vital.programs.texlive.enable = true;
    vital.programs.modern-utils.enable = true;

    services.nginx.enable = true;
    security.acme = {
      acceptTerms = true;
      email = "sample@example.com";
    };

    # vital.services.filerun = {
    #   enable = true;
    #   domain = "filerun.example.com";
    # };

    vital.services.gitea = {
      enable = true;
      domain = "gitea.example.com";
      port = 5965;
    };

    networking.hostName = "testvm";
    networking.hostId = "4ca9a368";
  };
}
