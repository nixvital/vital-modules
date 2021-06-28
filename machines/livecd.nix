# Unfortunately the current nix flakes does not have good support for
# cusotmized livecd. Therefore this file is not integrated into the
# flake.nix yet.
#
# Without flake, run the following command to build the iso
#
# nix-build '<nixpkgs/nixos>' -A config.system.build.isoImage -I nixos-config=livecd.nix

{config, pkgs, ...}:

{
  imports = [
    <nixpkgs/nixos/modules/installer/cd-dvd/installation-cd-graphical-gnome.nix>
    # Provide an initial copy of the NixOS channel so that the user
    # doesn't need to run "nix-channel --update" first.
    <nixpkgs/nixos/modules/installer/cd-dvd/channel.nix>
  ];

  environment.systemPackages = with pkgs; [
    emacs firefox git gparted
    fd silver-searcher lsd bat
  ];

  nix = {
    # The following is to enable Nix Flakes
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
}
