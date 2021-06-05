# To support running virtual machines with libvritd

{ config, pkgs, ... }:

{
  boot.kernelModules = [ "kvm-amd" "kvm-intel" ];
  virtualisation.libvirtd.enable = true;
  users = {
    extraUsers."${config.vital.mainUser}".extraGroups = [ "libvirtd" ];
    extraGroups.libvirtd = { members = [ "${config.vital.mainUser}" ]; };
  };
}
