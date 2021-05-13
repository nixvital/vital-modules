{
  description = "A collection of NixOS modules serving as building blocks to construct NixOS configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-20.09";
    
    # Use vitalpkgs, with the same nixpkgs
    vitalpkgs.url = "github:nixvital/vitalpkgs?rev=315fc6bd22ee01df568cf411bc64b90370dd15ea";
    vitalpkgs.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, vitalpkgs, ... }: let
    withVitalpkgs = module : {config, lib, pkgs, ...} : {
      imports = [ module ];
      nixpkgs.overlays = [ vitalpkgs.overlay ];
    };

  in {
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

    nixosConfigurations.test-vm = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = let
        test-vm = withVitalpkgs (import ./machines/test-vm.nix);
      in [ test-vm ];
    };
  };
}
