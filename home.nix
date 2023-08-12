{ pkgs, ... }:

{
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

    # File managment
    unzip
    unrar

    # Social
    discord

    # Dev
    docker

    # Coding
    neovim

    # Coding language specific

    # Nix
    rnix-lsp
    direnv

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
  ];

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
      nix-garbage = "nix-env --delete-generations old && nix-collect-garbage -d";
    };
  };

  programs.git = {
    enable = true;
    userName = "nktfh100";
    userEmail = "nktfh100@gmail.com";
    extraConfig.credential.helper = "store";
  };

  programs.vscode = {
    enable = true;
    enableUpdateCheck = false;
    userSettings = {
      "nix.enableLanguageServer" = true;
      "[nix]"."editor.tabSize" = 2;
      "files.encoding" = "utf8";
      "files.trimTrailingWhitespace" = true;
      "editor.formatOnType" = true;
      # "editor.fontFamily" = "";
    };
  };

  home.file.".vscode/argv.json".text = ''
    {
      "disable-hardware-acceleration": true,
      "enable-crash-reporter": false,
    }
  '';

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      "gtk-theme" = "Adwaita-dark";
      "color-scheme" = "prefer-dark";
    };
    "org/gnome/desktop/background" = {
      "picture-uri-dark" = "/etc/nixos/wallpaper.svg";
    };
    "org/gnome/desktop/wm/preferences" = {
      "button-layout" = ":minimize,maximize,close";
    };
    "org/gnome/shell" = {
      "favorite-apps" =
        "['firefox.desktop', 'org.gnome.Console.desktop', 'org.gnome.Nautilus.desktop', 'spotify.desktop']";
    };
  };

  programs.home-manager.enable = true;
}
