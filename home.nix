{ pkgs, ... }:

let theme = "Orchis-Dark";
in {
  home.stateVersion = "23.05";
  home.username = "nktfh100";

  home.packages = with pkgs; [
    # General
    htop
    wget
    neofetch
    bitwarden
    spotify
    google-chrome

    qbittorrent

    # Video/Audio
    vlc
    ffmpeg_6
    obs-studio

    # Social
    discord

    # Dev
    docker

    # Coding
    neovim

    # Coding language specific

    # Nix
    nixfmt

    # JS/TS
    nodejs_18
    yarn

    # Global npm packages
    nodePackages_latest.vercel

    # Python
    python311

    # Python packages
    python311Packages.flake8 # Linter
    python311Packages.mypy # Pyton static types
    python311Packages.black # Formatter

    # GNOME
    # gnome3.gnome-tweaks
    orchis-theme

    # GNOME extensions
    gnomeExtensions.user-themes
    gnomeExtensions.vitals
  ];

  programs.home-manager.enable = true;

  programs.command-not-found.enable = true;

  programs.bash = {
    enable = true;
    shellAliases = {
      la = "ls -a";
      nix-rebuild-home =
        "git add . && sudo nixos-rebuild switch --flake '.#nktfh100-home'";
      nix-rebuild-lab =
        "git add . && sudo nixos-rebuild switch --flake '.#nktfh100-lab'";
      nix-code = "cd /etc/nixos && code .";
      py = "python";
      dcb = "docker compose build";
      dcu = "docker compose up";
      dcud = "docker compose up";
      dcd = "docker compose down";
      dc = "docker compose";
      nix-garbage =
        "sudo nix-env --delete-generations old && sudo nix-collect-garbage -d";
    };
  };

  programs.git = {
    enable = true;
    userName = "nktfh100";
    userEmail = "me@nktfh100.com";
    extraConfig = {
      credential.helper = "store";
      http.postBuffer = "524288000";
    };
  };

  programs.vscode = {
    enable = true;
    enableUpdateCheck = false;
    userSettings = {
      "files.encoding" = "utf8";
      "files.trimTrailingWhitespace" = true;
      "editor.formatOnSave" = true;
      "editor.fontFamily" = "'ComicCodeLigatures Nerd Font'";
      "editor.fontLigatures" = true;
      "[nix]"."editor.tabSize" = 2;
      "[javascript]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
      "[json]"."editor.defaultFormatter" = "vscode.json-language-features";
      "prettier.tabWidth" = 4;
      "prettier.useTabs" = true;
    };
  };

  # To fix vscode blank screen
  home.file.".vscode/argv.json".text = ''
    {
      "disable-hardware-acceleration": true,
      "enable-crash-reporter": false,
    }
  '';

  gtk = {
    enable = true;

    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };

    theme = { name = "${theme}"; };
  };

  dconf.settings = {
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
}
