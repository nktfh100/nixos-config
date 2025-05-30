{
  description = "nktfh100's nixos configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin.url = "github:catppuccin/nix";
    # spicetify-nix.url = "github:Gerg-L/spicetify-nix"; # Doesn't work
    # spicetify-nix.inputs.nixpkgs.follows = "nixpkgs";
    minegrub-theme.url = "github:Lxtharia/minegrub-world-sel-theme";
  };

  outputs =
    {
      self,
      nixpkgs,
      # spicetify-nix,
      ...
    }@inputs:
    let
      commonModules = [
        (
          { pkgs, ... }:
          {
            _module.args.unstable = import inputs.unstable {
              inherit (pkgs.stdenv.targetPlatform) system;
              config.allowUnfree = true;
            };
          }
        )
        inputs.home-manager.nixosModules.home-manager
        inputs.minegrub-theme.nixosModules.default
        inputs.catppuccin.nixosModules.catppuccin
        {
          home-manager.users.nktfh100 = {
            imports = [ inputs.catppuccin.homeModules.catppuccin ];
          };
        }
      ];
      specialArgs = {
        # inherit spicetify-nix;
      };
    in
    {
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
