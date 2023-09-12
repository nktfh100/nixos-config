{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [ kitty ];
  home-manager.users.nktfh100.home.file.".config/kitty/kitty.conf".source =
    ./kitty.conf;

  home-manager.users.nktfh100.dconf.settings = {
    "org/gnome/desktop/default-applications/terminal" = {
      "exec" = "exec ~/.nix-profile/bin/kitty";
    };
  };
}
