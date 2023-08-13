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
      nix-garbage = "sudo nix-env --delete-generations old && sudo nix-collect-garbage -d";
    };
  };

  programs.git = {
    enable = true;
    userName = "nktfh100";
    userEmail = "nktfh100@gmail.com";
    extraConfig = {
      credential.helper = "store";
      http.postBuffer = "524288000";
    };
  };

  programs.vscode = {
    enable = true;
    enableUpdateCheck = false;
    userSettings = {
      "nix.enableLanguageServer" = true;
      "nix.serverPath" = "rnix-lsp";
      "[nix]"."editor.tabSize" = 2;
      "files.encoding" = "utf8";
      "files.trimTrailingWhitespace" = true;
      "editor.formatOnSave" = true;
      "editor.fontFamily" = "'ComicCodeLigatures Nerd Font'";
      "editor.fontLigatures" = true;
    };
  };

  # To fix vscode blank screen
  home.file.".vscode/argv.json".text = ''
    {
      "disable-hardware-acceleration": true,
      "enable-crash-reporter": false,
    }
  '';

  programs.home-manager.enable = true;
}
