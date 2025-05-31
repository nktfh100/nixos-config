{
  pkgs,
  unstable,
  spicetify-nix,
  ...
}:

let
  # spicePkgs = spicetify-nix.packages.${pkgs.system}.default;
  spicePkgs = spicetify-nix.legacyPackages.${pkgs.stdenv.system};
in
{
  # environment.systemPackages = with pkgs; [ spotify ];

  # imports = [ spicetify-nix.nixosModule ];
  imports = [
    spicetify-nix.nixosModules.spicetify
  ];

  programs.spicetify = {
    enable = true;
    spotifyPackage = unstable.spotify;
    theme = spicePkgs.themes.catppuccin;
    colorScheme = "macchiato";
    enabledExtensions = with spicePkgs.extensions; [
      fullAppDisplay
      # genre # https://github.com/the-argus/spicetify-nix/issues/50
      songStats
      wikify
      featureShuffle
      shuffle
    ];
  };
}
