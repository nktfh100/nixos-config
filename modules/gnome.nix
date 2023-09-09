

{ config, pkgs, ... }:

let
  theme = "Catppuccin-Macchiato-Standard-Blue-Dark";
  catppuccin = pkgs.catppuccin-gtk.override {
    accents = [ "blue" ];
    size = "standard";
    variant = "macchiato";
  };
  wallpaper = "file:///etc/nixos/wallpapers/nix-black.png";
in {
  services.xserver = {
    # Enable the GNOME Desktop Environment.
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

  home-manager.users.nktfh100.home.packages = with pkgs; [
    gnome3.gnome-tweaks
    gnome3.dconf-editor
    catppuccin-gtk

    gtk-engine-murrine
    gnome.gnome-themes-extra
    gtk3

    # GNOME extensions
    gnomeExtensions.user-themes
    gnomeExtensions.vitals
    gnomeExtensions.blur-my-shell
  ];

  home-manager.users.nktfh100.gtk = {
    enable = true;

    theme = {
      name = theme;
      package = catppuccin;
    };

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.catppuccin-papirus-folders;
    };

    # cursorTheme = {
    #   name = "Catppuccin-Macchiato-Mauve-Cursors";
    #   package = pkgs.catppuccin-cursors.macchiatoMauve;
    # };

    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
      gtk-key-theme-name = theme;
      gtk-icon-theme-name = "Papirus-Dark";
    };
  };

  home-manager.users.nktfh100.home.sessionVariables.GTK_THEME = theme;

  home-manager.users.nktfh100.dconf.settings = {
    "org/gnome/desktop/wm/preferences" = {
      button-layout = ":minimize,maximize,close";
      num-workspaces = 1;
    };
    "org/gnome/shell" = {
      favorite-apps = [
        "firefox.desktop"
        "Alacritty.desktop"
        "org.gnome.Nautilus.desktop"
        "spotify.desktop"
      ];
      disable-user-extensions = false;
      enabled-extensions = [
        "user-theme@gnome-shell-extensions.gcampax.github.com"
        "Vitals@CoreCoding.com"
        "blur-my-shell@aunetx"
      ];
    };
    "org/gnome/desktop/interface" = {
      gtk-theme = theme;
      color-scheme = "prefer-dark";
      enable-hot-corners = true;
    };
    "org/gnome/shell/extensions/user-theme" = { name = theme; };
    "org/gnome/desktop/background" = {
      picture-uri = wallpaper;
      picture-uri-dark = wallpaper;
    };
    "org/gnome/desktop/screensaver" = { picture-uri = wallpaper; };
    "org/gnome/mutter" = { center-new-windows = true; };
    "org/gnome/shell/extensions/vitals" = {
      show-storage = false;
      show-voltage = false;
      show-memory = true;
      show-fan = true;
      show-temperature = true;
      show-processor = true;
      show-network = true;
    };
    "org/gnome/desktop/sound".event-sounds = false;
    "org/gnome/terminal/legacy" = { theme-variant = "dark"; };
  };

  environment.gnome.excludePackages = (with pkgs; [ gnome-tour gnome-console ])
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
