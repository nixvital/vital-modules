{ config, lib, pkgs, ... }:

{
  imports = [
    ../foundations
  ];

  config = {
    networking.hostName = "testvm";
    networking.hostId = "4ca9a368";
  };
}
