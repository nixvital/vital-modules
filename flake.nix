{
  description = "A collection of NixOS modules serving as building blocks to construct NixOS configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  };

  outputs = { self, nixpkgs, ... }: {
    nixosModules = {
      # Import this so that you have a backbone that you can build
      # your machine up on.
      foundation = import ./foundations;
      
      # Individual Modules
      users = import ./modules/users;
    };

    nixosConfigurations = {
      # Run
      #
      # nixos-rebuild build-vm .#test-vm
      #
      # to test the build
      test-vm = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./machines/test-vm.nix
        ];
      };
    };
  };
}
