{ pkgs, unstable, spicetify-nix, ... }:

let spicePkgs = spicetify-nix.packages.${pkgs.system}.default;
in {
  imports = [ spicetify-nix.nixosModule ];

  programs.spicetify = {
    enable = true;
    spotifyPackage = unstable.spotify;
    theme = spicePkgs.themes.catppuccin-macchiato;
    colorScheme = "blue";

    enabledExtensions = with spicePkgs.extensions; [
      fullAppDisplay
      genre
      songStats
      wikify
      featureShuffle
    ];
  };
}
