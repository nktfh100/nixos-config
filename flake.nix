{
  description = "nktfh100's nixos configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    spicetify-nix.url = "github:the-argus/spicetify-nix";
    minegrub-theme.url =
      "github:nktfh100/minegrub-world-sel-theme/nixos-support";
  };

  outputs = { self, nixpkgs, unstable, home-manager, spicetify-nix
    , minegrub-theme, ... }@inputs:
    let
      commonModules = [
        ({ pkgs, ... }: {
          _module.args.unstable = import unstable {
            inherit (pkgs.stdenv.targetPlatform) system;
            config.allowUnfree = true;
          };
        })
        home-manager.nixosModules.home-manager
        minegrub-theme.nixosModules.default
      ];
      specialArgs = { inherit spicetify-nix; };
    in {
      nixosConfigurations.nktfh100-alpha = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = commonModules ++ [ ./hosts/alpha/configuration.nix ];
        specialArgs = specialArgs;
      };

      nixosConfigurations.nktfh100-beta = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = commonModules ++ [ ./hosts/beta/configuration.nix ];
        specialArgs = specialArgs;
      };

      nixosConfigurations.nktfh100-gamma = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = commonModules ++ [ ./hosts/gamma/configuration.nix ];
        specialArgs = specialArgs;
      };

      nixosConfigurations.nktfh100-delta = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = commonModules ++ [ ./hosts/delta/configuration.nix ];
        specialArgs = specialArgs;
      };
    };
}
