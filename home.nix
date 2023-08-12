{ pkgs, ...}:

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
    nixfmt # Format nix files

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
      nix-rebuild-home = "sudo nixos-rebuild switch --flake '/etc/nixos#nktfh100-home'";
      nix-rebuild-lab = "sudo nixos-rebuild switch --flake '/etc/nixos#nktfh100-lab'";
      nix-code = "cd /etc/nixos && code .";
      py = "python";
      dcb = "docker compose build";
      dcu = "docker compose up";
      dcud = "docker compose up";
      dcd = "docker compose down";
      dc = "docker compose";
    };
  };

  programs.git = {
    enable = true;
    userName = "nktfh100";
    userEmail = "nktfh100@gmail.com";
    extraConfig.credential.helper = "store";
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      "gtk-theme" = "Adwaita-dark";
      "color-scheme" = "prefer-dark";
    };
    "org/gnome/desktop/background" = {
      "picture-uri-dark" = "/etc/nixos/wallpaper.svg";
    };
    "org/gnome/shell" = {
      "favorite-apps" = "['firefox.desktop', 'org.gnome.Console.desktop', 'org.gnome.Nautilus.desktop']";
    };
    "org/gnome/desktop/wm/preferences" = {
      "button-layout" = ":minimize,maximize,close";
    };
  };

  programs.home-manager.enable = true;
}