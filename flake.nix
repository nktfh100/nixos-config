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
    spicetify-nix.url = "github:the-argus/spicetify-nix";
  };

  outputs =
    { self, nixpkgs, unstable, home-manager, spicetify-nix, ... }@inputs:
    let
      commonModules = [
        ({ pkgs, ... }: {
          _module.args.unstable = import unstable {
            inherit (pkgs.stdenv.targetPlatform) system;
            config.allowUnfree = true;
          };
        })
        home-manager.nixosModules.home-manager
        inputs.minegrub-theme.nixosModules.default
      ];
      specialArgs = { inherit spicetify-nix; };
    in {
      nixosConfigurations.nktfh100-home = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = commonModules ++ [ ./hosts/home-pc/configuration.nix ];
        specialArgs = specialArgs;
      };

      nixosConfigurations.nktfh100-lab = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = commonModules ++ [ ./hosts/lab-pc/configuration.nix ];
        specialArgs = specialArgs;
      };
    };
}
