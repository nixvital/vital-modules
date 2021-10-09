{
  description = "A collection of NixOS modules serving as building blocks to construct NixOS configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.05";

    nixpkgs-unstable.url = "github:NixOS/nixpkgs?rev=f924460e91cba6473c5dc4b8ccb1a1cfc05bc2d7";
    
    # Use vitalpkgs, with the same nixpkgs
    vitalpkgs.url = "github:nixvital/vitalpkgs";
    vitalpkgs.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, vitalpkgs, ... }: let
    withVitalpkgs = module : {config, lib, pkgs, ...} : {
      imports = [ module ];
      nixpkgs.overlays = [
        vitalpkgs.overlay
        (final: prev: {
          chia = nixpkgs-unstable.legacyPackages."${prev.system}".chia;
        })
      ];
    };

  in {
    # This is to enable building the livecd iso with `nix build .#livecd`
    packages."x86_64-linux" = {
      livecd = self.nixosConfigurations.livecd.config.system.build.isoImage;
    };
    
    nixosModules = {
      # Import this so that you have a backbone that you can build
      # your machine up on.
      foundation = withVitalpkgs (import ./foundations);
      
      # Individual Modules
      graphical = import ./modules/graphical;
      users = import ./modules/users;
      steam = import ./modules/games/steam.nix;

      # - Add-on modules
      docker = import ./modules/addons/docker.nix;
      laptop-lids = import ./modules/addons/laptop-lids.nix;
      iphone-connect = import ./modules/addons/iphone-connect.nix;
    };

    nixosConfigurations = {
      # The live cd iso can be built with
      #
      # GC_DONT_GC=1 nix build .#nixosConfigurations.livecd.config.system.build.isoImage
      livecd = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        modules = [
          "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-graphical-gnome.nix"
          ./modules/livecd.nix
        ];
      };

      # Run
      #
      # nixos-rebuild build-vm .#test-vm
      #
      # to test the build
      test-vm = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = let
          test-vm = withVitalpkgs (import ./machines/test-vm.nix);
        in [ test-vm ];
      };

      test-container = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./foundations/container.nix
          ./machines/test-container.nix
        ];
      };
    };
  };
}
