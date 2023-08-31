{
  description = "nktfh100's nixos configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, unstable, home-manager, ... }@inputs: {

    nixosConfigurations.nktfh100-home = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = let
        defaults = { pkgs, ... }: {
          _module.args.unstable = import inputs.unstable {
            inherit (pkgs.stdenv.targetPlatform) system;
          };
        };
      in [
        defaults
        ./common.nix
        ./hosts/home-pc/configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.users.nktfh100 = ./home.nix;
        }
      ];
    };

    nixosConfigurations.nktfh100-lab = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = let
        defaults = { pkgs, ... }: {
          _module.args.unstable = import inputs.unstable {
            inherit (pkgs.stdenv.targetPlatform) system;
          };
        };
      in [
        defaults
        ./common.nix
        ./hosts/lab-pc/configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.users.nktfh100 = ./home.nix;
        }
      ];
    };

  };
}
