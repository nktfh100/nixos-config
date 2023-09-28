{ pkgs, unstable, ... }:

{
  home-manager.users.nktfh100.home.packages = with pkgs; [ unstable.vscode ];

  home-manager.users.nktfh100.home.file.".config/Code/User/settings.json".source =
    ./settings.json;
}
