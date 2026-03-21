{ pkgs, ... }:

{
  home-manager.users.nktfh100.home.file.".config/opencode/opencode.json".source = ./opencode.json;

  # (opencode-nix is disabled untill they fix the github copilot issues...)
  # opencode comes from the opencode-nix overlay in flake.nix.
  # Update to latest stable release tag with:
  #   nix flake update opencode-nix
  home-manager.users.nktfh100.home.packages = with pkgs; [ opencode ];

  # https://github.com/backnotprop/plannotator/issues/61#issuecomment-3827032108
  programs.nix-ld.enable = true;
}
