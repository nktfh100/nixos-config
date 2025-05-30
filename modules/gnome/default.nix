{
  unstable,
  lib,
  pkgs,
  ...
}:

let
  wallpaper = "file:///etc/nixos/wallpapers/nix-black.png";
in
{
  imports = [ ./gnome-catppuccin.nix ];

  services.xserver = {
    # Enable the GNOME Desktop Environment.
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    displayManager.gdm.wayland = false;
  };

  # home-manager.backupFileExtension = "hm-backup";

  home-manager.users.nktfh100.home.packages =
    with pkgs;
    [
      gnome-tweaks
      dconf-editor

      gtk-engine-murrine
      gnome-themes-extra
      gtk3
    ]
    ++ (with pkgs.gnomeExtensions; [
      # GNOME extensions
      user-themes
      vitals
      gtile
      just-perfection
      media-controls
      blur-my-shell
    ])
    ++ (with unstable.gnomeExtensions; [
      # useless-gaps - Not working anymore
      appindicator
      burn-my-windows
      # hide-top-bar
    ]);

  home-manager.users.nktfh100.gtk = {
    enable = true;
    gtk3.extraConfig = {
      gtk-application-prefer-dark-theme = true;
    };
  };

  home-manager.users.nktfh100.dconf.settings = {
    "org/gnome/desktop/wm/preferences" = {
      button-layout = ":minimize,maximize,close";
      num-workspaces = 1;
    };
    "org/gnome/shell" = {
      favorite-apps = [
        "firefox.desktop"
        "code.desktop"
        "kitty.desktop"
        "org.gnome.Nautilus.desktop"
        "spotify.desktop"
        "smartcode-stremio.desktop"
      ];
      disable-user-extensions = false;
      enabled-extensions = [
        "user-theme@gnome-shell-extensions.gcampax.github.com"
        "Vitals@CoreCoding.com"
        "blur-my-shell@aunetx"
        "burn-my-windows@schneegans.github.com"
        "gTile@vibou"
        "just-perfection-desktop@just-perfection"
        "mediacontrols@cliffniff.github.com"
        "appindicatorsupport@rgcjonas.gmail.com"
        # "useless-gaps@pimsnel.com"
        "drive-menu@gnome-shell-extensions.gcampax.github.com"
        "hidetopbar@mathieu.bidon.ca"
      ];
    };
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      enable-hot-corners = true;
      gtk-enable-primary-paste = false;
    };
    "org/gnome/desktop/background" = lib.mkDefault {
      picture-uri = wallpaper;
      picture-uri-dark = wallpaper;
    };
    "org/gnome/desktop/screensaver" = lib.mkDefault { picture-uri = wallpaper; };
    "org/gnome/mutter" = {
      center-new-windows = true;
    };
    "org/gnome/shell/extensions/vitals" = {
      show-storage = false;
      show-voltage = false;
      show-fan = false;
      show-network = false;
      hot-sensors = [
        "_processor_usage_"
        "_memory_usage_"
        "_temperature_processor_0_"
      ];
    };
    "org/gnome/shell/extensions/blur-my-shell/applications" = {
      blur = true;
      dynamic-opacity = false;
      whitelist = [
        "Code"
        "kitty"
      ];
    };
    "org/gnome/shell/extensions/blur-my-shell" = {
      hacks-level = 1;
    };
    "org/gnome/shell/extensions/burn-my-windows" = {
      active-profile = "/home/nktfh100/.config/burn-my-windows/profiles/1694335536777219.conf";
    };
    "org/gnome/shell/extensions/gtile" = {
      global-presets = true;
      grid-sizes = "3x3,2x2";
      target-presets-to-monitor-of-mouse = true;
      moveresize-enabled = false;
      show-toggle-tiling = [ "<Shift><Alt>a" ];
    };
    "org/gnome/shell/extensions/just-perfection" = {
      app-menu = false;
      activities-button = false;
      panel-notification-icon = false;
      clock-menu-position = 2;
    };
    "org/gnome/shell/extensions/mediacontrols" = {
      show-control-icons-seek-backward = false;
      show-control-icons-seek-forward = false;
      show-separators = false;
      show-sources-menu = false;
      scroll-labels = false;
      mouse-action-left = "PLAY_PAUSE";
      blacklisted-players = [
        "google-chrome.desktop"
        "firefox.desktop"
      ];
    };
    # Used for polybar
    # "org/gnome/shell/extensions/hidetopbar" = {
    #   mouse-sensitive = false;
    #   show-in-overview = true;
    #   hot-corner = true;
    #   enable-intellihide = true;
    # };
    # "org/gnome/shell/extensions/useless-gaps" = {
    #   no-gap-when-maximized = true;
    #   gap-size = 10;
    # };
    "org/gnome/desktop/sound" = {
      event-sounds = false;
    };
    "org/gnome/terminal/legacy" = {
      theme-variant = "dark";
    };
    "org/gnome/mutter" = {
      edge-tiling = true;
    };
    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
      ];
    };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      name = "Open kitty terminal";
      command = "kitty";
      binding = "<Super><Shift>t";
    };
    "org/gnome/mutter/keybindings" = {
      toggle-tiled-left = [ "<Super>a" ];
      toggle-tiled-right = [ "<Super>d" ];
    };
    "org/gnome/desktop/wm/keybindings" = {
      maximize = [ "<Super>w" ];
      minimize = [ "<Super>q" ];
      unmaximize = [ "<Super>s" ];
      move-to-monitor-up = [
        "<Shift><Super>w"
        "<Shift><Super>Up"
      ];
      move-to-monitor-down = [
        "<Shift><Super>s"
        "<Shift><Super>Down"
      ];
      move-to-monitor-left = [
        "<Shift><Super>a"
        "<Shift><Super>Left"
      ];
      move-to-monitor-right = [
        "<Shift><Super>d"
        "<Shift><Super>Right"
      ];
    };
    "org/gnome/shell/keybindings" = {
      toggle-overview = [ ];
    };
  };

  home-manager.users.nktfh100.home.file.".config/burn-my-windows/profiles/1694335536777219.conf".text =
    ''
      [burn-my-windows-profile]
      fire-enable-effect=false
      incinerate-enable-effect=true
      incinerate-scale=0.90000000000000002
      incinerate-color='rgb(138,173,244)'
      incinerate-animation-time=1073
      incinerate-turbulence=0.31
      profile-high-priority=true
    '';

  environment.gnome.excludePackages =
    (with pkgs; [ gnome-tour ])
    ++ (with pkgs; [
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
