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
    google-chrome

    qbittorrent

    # Video/Audio
    vlc
    audacity
    obs-studio

    # Social
    discord

    # Dev
    docker
    gh # Github CLI
    gnumake # Make

    # Coding language specific

    # Nix
    nixfmt-classic

    # JS/TS
    nodejs_18
    yarn

    # Global npm packages
    nodePackages_latest.vercel

    # Python
    python311

    # Python packages
    python311Packages.flake8 # Linter
    python311Packages.black # Formatter

    # Go
    go
    gopls # Go language server
    delve # Go debugger

    stremio # Media center
  ];

  # Make firefox the default browser
  xdg.mimeApps.defaultApplications = {
    "text/html" = ["firefox.desktop"];
    "x-scheme-handler/http" = ["firefox.desktop"];
    "x-scheme-handler/https" = ["firefox.desktop"];
  };

  programs.home-manager.enable = true;

  programs.command-not-found.enable = true;

  programs.bash = {
    enable = true;
    shellAliases = {
      la = "ls -a";
      nix-code = "code /etc/nixos";
      nix-garbage =
        "sudo nix-env --delete-generations old && sudo nix-store --gc && sudo nix-collect-garbage -d && sudo nix store optimise && sudo rm -rf ~/.local/share/Trash/*";
      py = "python";
      dcb = "docker compose build";
      dcu = "docker compose up";
      dcud = "docker compose up";
      dcd = "docker compose down";
      dcsa = "docker stop $(docker ps -a -q)";
      dc = "docker compose";
    };
    bashrcExtra = ''
      nix-rebuild() {
        local flake_name="nktfh100-$1"
        local rebuild_subcommand=$2
        shift 2
        local extra_args="$@"

        cd /etc/nixos && git add .  && cd - > /dev/null && sudo nixos-rebuild "$rebuild_subcommand" --flake "/etc/nixos#$flake_name" $extra_args
      }
    '';
  };

  programs.git = {
    enable = true;
    userName = "nktfh100";
    userEmail = "me@malachi.io";
    extraConfig = {
      credential.helper = "store";
      http.postBuffer = "524288000";
    };
  };
}
