{ pkgs, ... }:

{
  home.stateVersion = "24.05";
  home.username = "nktfh100";

  home.packages = with pkgs; [
    # General
    htop
    wget
    fastfetch
    bitwarden
    bitwarden-cli
    google-chrome
    anki-bin
    mplayer # For anki

    stremio # Media center

    psmisc # To use fuser

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
    # nixfmt-classic

    # JS/TS
    nodejs_20
    yarn

    # Global npm packages
    nodePackages_latest.vercel

    # Python
    python312

    # Python packages
    python312Packages.flake8 # Linter
    python312Packages.black # Formatter

    # Go
    gopls # Go language server
    delve # Go debugger
  ];

  # Make firefox the default browser
  xdg.mimeApps.defaultApplications = {
    "text/html" = [ "firefox.desktop" ];
    "x-scheme-handler/http" = [ "firefox.desktop" ];
    "x-scheme-handler/https" = [ "firefox.desktop" ];
  };

  programs.home-manager.enable = true;

  programs.command-not-found.enable = true;

  programs.bash = {
    enable = true;
    shellAliases = {
      la = "ls -a";
      nix-code = "code /etc/nixos";
      nix-garbage = "sudo nix-env --delete-generations old && sudo nix-store --gc && sudo nix-collect-garbage -d && sudo nix store optimise && sudo rm -rf ~/.local/share/Trash/*";
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

        if [[ "$flake_name" != "$(hostname)" ]]; then
            echo "Warning: The flake name '$flake_name' does not match the current hostname '$(hostname)'."
            read -p "Do you want to proceed? (y/N): " confirmation
            if [[ "$confirmation" != "y" && "$confirmation" != "Y" ]]; then
                echo "Aborted."
                return 1
            fi
        fi

        cd /etc/nixos && git add .  && cd - > /dev/null && sudo nixos-rebuild "$rebuild_subcommand" --flake "/etc/nixos?submodules=1#$flake_name" $extra_args
      }

      kill-port() {
        sudo fuser -k $1/tcp
      }

      nvima() {
        export GEMINI_API_KEY="$(bw get notes gemini-api-key)"
        nvim
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
      submodules.recurse = "true";
    };
  };
}
