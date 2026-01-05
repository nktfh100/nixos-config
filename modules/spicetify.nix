{
  pkgs,
  spicetify-nix,
  ...
}:

let
  spicePkgs = spicetify-nix.legacyPackages.${pkgs.stdenv.system};
in
{
  imports = [
    spicetify-nix.nixosModules.spicetify
  ];

  programs.spicetify = {
    enable = true;
    # spotifyPackage = unstable.spotify;
    theme = spicePkgs.themes.catppuccin;
    colorScheme = "macchiato";
    enabledExtensions = with spicePkgs.extensions; [
      fullAppDisplay
      songStats
      wikify
      featureShuffle
      shuffle
      betterGenres
    ];
  };
}
