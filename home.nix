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

    #poetry # Python dependency management
    pre-commit # pre-commit hooks

    # Python packages
    python311Packages.flake8 # Linter
    python311Packages.black # Formatter

    # Hive stuff
    #mypy # Pyton static types
    #python311Packages.psycopg2
    postgresql # Required for psycopg2..
    gcc13 # Required for psycopg2..
    mypy
  ];

  programs.home-manager.enable = true;

  programs.command-not-found.enable = true;

  programs.bash = {
    enable = true;
    shellAliases = {
      la = "ls -a";
      nix-code = "code /etc/nixos";
      nix-garbage =
        "sudo nix-env --delete-generations old && sudo nix-collect-garbage -d";
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

        cd /etc/nixos && git add .  && cd - > /dev/null && sudo nixos-rebuild "$rebuild_subcommand" --flake "/etc/nixos#$flake_name"
      }
    '';
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
}
