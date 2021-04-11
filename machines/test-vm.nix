{ config, lib, pkgs, ... }:

{
  imports = [
    ../foundations
  ];

  config = {
    vital.mainUser = "tester";
    vital.graphical.enable = true;

    vital.pre-installed.level = 5;
    
    vital.games.steam.enable = true;
    
    networking.hostName = "testvm";
    networking.hostId = "4ca9a368";
  };
}
