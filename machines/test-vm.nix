{ config, lib, pkgs, ... }:

{
  imports = [
    ../foundations
  ];

  config = {
    vital.mainUser = "tester";
    
    networking.hostName = "testvm";
    networking.hostId = "4ca9a368";
  };
}
