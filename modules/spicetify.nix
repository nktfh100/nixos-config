{
  pkgs,
  unstable,
  spicetify-nix,
  ...
}:

# let
#   spicePkgs = spicetify-nix.packages.${pkgs.system}.default;
# in
{

  environment.systemPackages = with pkgs; [ spotify ];

  # Spicetify doesnt work anymore :(

  # imports = [ spicetify-nix.nixosModule ];

  # programs.spicetify = {
  #   enable = true;
  # spotifyPackage = unstable.spotify;
  # theme = spicePkgs.themes.catppuccin;
  # colorScheme = "macchiato";

  #   enabledExtensions = with spicePkgs.extensions; [
  #     fullAppDisplay
  #     # genre # https://github.com/the-argus/spicetify-nix/issues/50
  #     songStats
  #     wikify
  #     featureShuffle
  #   ];
  # };
}
