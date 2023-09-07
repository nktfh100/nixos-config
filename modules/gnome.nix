

{ config, pkgs, ... }:

let theme = "Orchis-Dark";
in {
  services.xserver = {
    # Enable the GNOME Desktop Environment.
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

  home-manager.users.nktfh100.home.packages = with pkgs; [
    # gnome3.gnome-tweaks
    orchis-theme

    # GNOME extensions
    gnomeExtensions.user-themes
    gnomeExtensions.vitals
  ];

  home-manager.users.nktfh100.gtk = {
    enable = true;

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    theme = { name = "${theme}"; };
  };

  home-manager.users.nktfh100.dconf.settings = {
    "org/gnome/desktop/wm/preferences" = {
      button-layout = ":minimize,maximize,close";
      num-workspaces = 1;
    };
    "org/gnome/shell" = {
      favorite-apps = [
        "firefox.desktop"
        "org.gnome.Console.desktop"
        "org.gnome.Nautilus.desktop"
        "spotify.desktop"
      ];
      disable-user-extensions = false;
      enabled-extensions = [
        "user-theme@gnome-shell-extensions.gcampax.github.com"
        "Vitals@CoreCoding.com"
      ];
    };
    "org/gnome/desktop/interface" = {
      gtk-theme = "${theme}";
      color-scheme = "prefer-dark";
      enable-hot-corners = true;
    };
    "org/gnome/shell/extensions/user-theme" = { name = "${theme}"; };
    "org/gnome/desktop/background" = {
      picture-uri = "file:///etc/nixos/wallpaper.svg";
      picture-uri-dark = "file:///etc/nixos/wallpaper.svg";
    };
    "org/gnome/desktop/screensaver" = {
      picture-uri = "file:///etc/nixos/wallpaper.svg";
    };
    "org/gnome/mutter" = { center-new-windows = true; };
  };

  environment.gnome.excludePackages = (with pkgs; [ gnome-tour ])
    ++ (with pkgs.gnome; [
      gnome-music
      gnome-weather
      gnome-clocks
      gnome-contacts
      gnome-characters
      epiphany
      geary
      totem
      tali
      iagno
      hitori
      atomix
    ]);
}
