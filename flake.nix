{
  description = "nktfh100's nixos configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.05";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    minegrub-theme.url = "github:nktfh100/minegrub-theme/nixos-fix-splash";
  };

  outputs = { self, nixpkgs, unstable, home-manager, ... }@inputs:
    let
      defaults = { pkgs, ... }: {
        _module.args.unstable = import unstable {
          inherit (pkgs.stdenv.targetPlatform) system;
          config.allowUnfree = true;
        };
      };
    in {
      nixosConfigurations.nktfh100-home = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          defaults
          home-manager.nixosModules.home-manager
          inputs.minegrub-theme.nixosModules.default
          ./hosts/home-pc/configuration.nix
        ];
      };

      nixosConfigurations.nktfh100-lab = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          defaults
          home-manager.nixosModules.home-manager
          inputs.minegrub-theme.nixosModules.default
          ./hosts/lab-pc/configuration.nix
        ];
      };

    };
}
