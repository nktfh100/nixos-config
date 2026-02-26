{ pkgs, ... }:

{
  home-manager.users.nktfh100.home.file.".config/opencode/opencode.json".source = ./opencode.json;

  home-manager.users.nktfh100.home.packages = with pkgs; [ opencode ];

  # https://github.com/backnotprop/plannotator/issues/61#issuecomment-3827032108
  programs.nix-ld.enable = true;
}
